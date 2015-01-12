function gradient = vec_stochastic_gradientOfLoss_A2(Q,A ,V_old , C,pp_details_qid_set,label_set)
minibatch_num = 10;
 gradient = V_old;
 pps_index_by_qid_set = pp_details_qid_set(:,2);
for i = 1:size(V_old,1)
    gradient{i} = zeros(size(gradient{i}));
end
alpha_hat = GetAlpha_by_vMatrix(V_old,pps_index_by_qid_set);

alpha = A'*alpha_hat;
%find out non-empty preference pair qids
for i = 1:size(pps_index_by_qid_set,1)
    pps_num(i,1) = size(pps_index_by_qid_set{i},1);
end
rows = find(pps_num>0);
%random pick out nimibatch_num pps for calculating gradient
updating_pps = zeros(minibatch_num,2);
for i = 1:minibatch_num
    tmp = unidrnd(size(rows,1));
    non_empty_qid_index = rows(tmp,1);
    random_pick_qid_pp_index = unidrnd(size(pps_index_by_qid_set{non_empty_qid_index},1));
    %the first column is the non empty qid index,the second column is
    updating_pps(i,1) = non_empty_qid_index;   
    updating_pps(i,2) = random_pick_qid_pp_index;
end
updating_pps = unique(updating_pps,'rows');
stochastic_qid_set = unique(updating_pps(:,1));
for i = 1:length(stochastic_qid_set)
    pps_index_by_qid = updating_pps(updating_pps(:,1) == stochastic_qid_set(i),2);    
    stochastic_pps_details_by_qid= pps_index_by_qid_set{stochastic_qid_set(i),1}(pps_index_by_qid,:);
    v_ik_set_qid = unique([stochastic_pps_details_by_qid(:,5);stochastic_pps_details_by_qid(:,6)]);
    % iterate all v_ik in stochastic_pps_details_by_qid
    for j = 1:length(v_ik_set_qid);
        v_jk_set_qid = GetV_jk_set_by_V_ik(v_ik_set_qid(j),pps_index_by_qid_set{stochastic_qid_set(i)});
        pp_ijk_global_index_set = GetPPs_ijk_global_index(pps_index_by_qid_set,stochastic_qid_set(i),v_ik_set_qid(j));
        gradient_regular_coeff_vec = A(pp_ijk_global_index_set,:)*Q*alpha;
        gradient_regular_qid_ik = gradient_regular_coeff_vec' * V_old{stochastic_qid_set(i)}(v_jk_set_qid,:);
        %gradient_regular_coeff_vec = A(pp_ijk_global_index_set,:)*(Q*alpha);
        %gradient_regular_coeff_matrix = zeros(size(pp_ijk_global_index_matrix));
%         tic;
        tmp = 1-A*(Q*alpha);
        tmp2 = A(tmp>0,:)*(Q*A(pp_ijk_global_index_set,:)');
        gradient_loss_coeff_vec = sum(tmp2);
        gradient_loss_qid_ik = gradient_loss_coeff_vec * V_old{stochastic_qid_set(i)}(v_jk_set_qid,:);
        gradient_qid_ik_vec = gradient_regular_qid_ik - C * gradient_loss_qid_ik;
        gradient{stochastic_qid_set(i)}(v_ik_set_qid(j),:) = gradient_qid_ik_vec;  
        
    end    
end
end

function v_qid_jk_set2 = GetV_jk_set_by_V_ik(v_qid_ik_index,sample_pp_index)
% v_qid_jk_set = [];
if isempty(sample_pp_index)
    return;
end
v_qid_jk_set2 = [sample_pp_index(sample_pp_index(:,5)==v_qid_ik_index,6) ...
    ;sample_pp_index(sample_pp_index(:,6)==v_qid_ik_index,5)];
end

function pp_ijk_global_index = GetPPs_ijk_global_index(pps_index_by_qid_set,qid_index,v_qid_ik)
intercept_length = 0;
for i=1:1:(qid_index-1)
    intercept_length = intercept_length + size(pps_index_by_qid_set{i},1);
end
% [row1]= find(sample_pp_index_cell{qid_index}(:,5)==v_qid_ik);
% [row2]= find(sample_pp_index_cell{qid_index}(:,6)==v_qid_ik);
[row3]= find(pps_index_by_qid_set{qid_index}(:,5)==v_qid_ik|pps_index_by_qid_set{qid_index}(:,6)==v_qid_ik);
pp_ijk_global_index = row3 + intercept_length;
end

function alpha_hat = GetAlpha_by_vMatrix(V,pps_index_by_qid_set)
alpha_cell = cell(length(pps_index_by_qid_set),1);
for i = 1:length(pps_index_by_qid_set)    
    pps_qid = pps_index_by_qid_set{i,1};
    if isempty(pps_qid)
        continue;
    end
    j = 1:size(pps_qid,1);
    alpha_cell{i,1}(j,1) = sum(V{i}(pps_qid(j,5),:).*V{i}(pps_qid(j,6),:),2);
end
alpha_hat = [];
for i = 1:length(alpha_cell)
    alpha_hat = [alpha_hat;alpha_cell{i}];
end
end