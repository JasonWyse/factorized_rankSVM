function [ alpha_hat, w_fac, function_val ] = rankSVM_fac_A( label_set,pp_details_qid_set, data_fold_train,data_fold_vali,data_fold_test,sample_pp_fea,...
    Q,A,C,max_iterate_num,V,epsilon,original_data_dir,evaluateInput_dir,evaluateOutput_dir,eval_score_perl_file)
%RANKSVM_FAC Summary of this function goes here
%   Detailed explanation goes here
pps_index_by_qid_set  = pp_details_qid_set(:,2);
alpha_hat = GetAlpha_by_vMatrix(V,pps_index_by_qid_set);
w = alpha_hat'*sample_pp_fea;
GetNDCG(num2str(0),w,data_fold_train,data_fold_vali,data_fold_test,...
    original_data_dir,evaluateInput_dir,evaluateOutput_dir,eval_score_perl_file);

effi = 5;
power = 3;
eta = effi*(10^(-power));
V_old = V;
V_new = V;
%old_fun_val = lossFun(gram_matrix ,pps_index_by_qid_set, V_old, C);
old_fun_val = lossFun_A(Q,A , V_old, C,pps_index_by_qid_set);
function_val(1,1) = old_fun_val;
ite_num = 0;
while 1
    tic;
    %     gradient = vec_gradientOfLoss(gram_matrix ,pps_index_by_qid_set, V_old, C);
    %gradient = vec_gradientOfLoss_A(Q,A ,V_old , C,pps_index_by_qid_set);
    %gradient2 = vec_gradientOfLoss_A2(Q,A ,V_old , C,pps_index_by_qid_set,pp_details_qid_set,label_set);
    gradient2 = vec_stochastic_gradientOfLoss_A2(Q,A ,V_old , C,pp_details_qid_set);
    %      gradient = vec_gradientOfLoss_A(Q,A ,alpha_old , C);
    t1 = toc;
    tic;
    [proper_eta,new_fun_val,V_new] = find_eta(Q,A,C,eta,V_old,gradient2,old_fun_val,pps_index_by_qid_set);
    t2 = toc;
    %     new_fun_val = lossFun(gram_matrix ,pps_index_by_qid_set, V_new, C);
    diff = abs(old_fun_val-new_fun_val);
    if(diff > epsilon && ite_num < max_iterate_num)
        V_old = V_new;
        ite_num = ite_num + 1;
        function_val(ite_num,1) = new_fun_val;
        fprintf('ite%d:old_fun_val=%f\tnew_fun_val=%f\tdiff=%f\n',ite_num,old_fun_val,new_fun_val,diff);
        old_fun_val = new_fun_val;
        if diff<200
            eta = proper_eta;
        end
%         if rem(ite_num,50) ==0
%             disp([ite_num,diff,new_fun_val]);
        if rem(ite_num,50) ==0
            alpha_hat = GetAlpha_by_vMatrix(V_new,pps_index_by_qid_set); 
            w = alpha_hat'*sample_pp_fea;
            w_file_name =  [evaluateOutput_dir 'w_ite' num2str(ite_num) '.txt'];
            alpha_hat_file_name = [evaluateOutput_dir 'alpha_hat_ite' num2str(ite_num) '.txt'];
            write2file( evaluateOutput_dir,w_file_name,w' );
            write2file( evaluateOutput_dir,alpha_hat_file_name,alpha_hat );
            GetNDCG(num2str(ite_num),w,data_fold_train,data_fold_vali,data_fold_test,...
                original_data_dir,evaluateInput_dir,evaluateOutput_dir,eval_score_perl_file);
        end
    else
        break;
    end
end
 fprintf('diff=%f\n',diff);
fun_val_file_name =  [evaluateOutput_dir 'fun_val_C_' num2str(C) '.txt'];
 write2file( evaluateOutput_dir,fun_val_file_name,function_val );
alpha_hat = GetAlpha_by_vMatrix(V_new,pps_index_by_qid_set); 
w_fac = alpha_hat'*sample_pp_fea;
end

function w = getW(A,alpha_new,sample_pp_fea)
%gmres_A = sparse(A*A')+ sparse(eye(size(A*A'))*0.001);
gmres_A = sparse(A*A');
gmres_B = A*alpha_new;
alpha_hat_final = gmres(gmres_A,gmres_B);
w = alpha_hat_final'*sample_pp_fea;
end

function [proper_eta,new_fun_val,V_new] = find_eta(Q,A,C,eta,V_old,gradient,old_fun_val,pps_index_by_qid_set)
while 1
    V_new = updateV_with_gradient(V_old, gradient,eta);
    new_fun_val = lossFun_A(Q,A , V_new, C,pps_index_by_qid_set);
    if(new_fun_val<old_fun_val)
        break;
    else
        eta = eta/2;
    end
end
proper_eta = eta;
end

function V_new = updateV_with_gradient(V_old, gradient,eta)
V_new = V_old;
for i = 1:length(V_old)
    if isempty(gradient{i})
        continue;
    end
    V_new{i} = V_old{i} - eta*gradient{i};
end
end

function gradient = vec_gradientOfLoss_A(Q,A ,V_old , C,pps_index_by_qid_set)
gradient = V_old;
V = V_old;
alpha_hat = GetAlpha_by_vMatrix(V,pps_index_by_qid_set);

alpha = A'*alpha_hat;
for i = 1:length(V)  
    tic;
    for v_qid_ik = 1:size(V{i},1)        
        % calculate the v_jk index set relateing to v_ik under the same qid
        v_jk_set_qid = GetV_jk_set_by_V_ik(v_qid_ik,pps_index_by_qid_set{i});
        pp_ijk_global_index_set = GetPPs_ijk_global_index(pps_index_by_qid_set,i,v_qid_ik);
        gradient_regular_coeff_vec = A(pp_ijk_global_index_set,:)*(Q*alpha);
        %gradient_regular_coeff_vec = alpha'*gram_matrix(:,pp_ijk_global_index_set);
        gradient_regular_qid_ik = gradient_regular_coeff_vec' * V{i}(v_jk_set_qid,:);
        tmp = 1-A*(Q*alpha);
              
        tmp2 = A(tmp>0,:)*(Q*A(pp_ijk_global_index_set,:)');
        gradient_loss_coeff_vec = sum(tmp2);
        gradient_loss_qid_ik = gradient_loss_coeff_vec * V{i}(v_jk_set_qid,:);
        gradient_qid_ik_vec = gradient_regular_qid_ik - C * gradient_loss_qid_ik;
        gradient{i}(v_qid_ik,:) = gradient_qid_ik_vec;      
        
    end
    t1 = toc;
end
end

function gradient = vec_stochastic_gradientOfLoss_A2(Q,A ,V_old , C,pp_details_qid_set)
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

%shuffled_V = shuffle_V_old(V_old)

function gradient = vec_gradientOfLoss_A2(Q,A ,V_old , C,pps_index_by_qid_set,pp_details_qid_set,label_set)
gradient = V_old;
V = V_old;
alpha_hat = GetAlpha_by_vMatrix(V,pps_index_by_qid_set);

alpha = A'*alpha_hat;
tmp = 1-A*(Q*alpha);
for i = 1:length(V)
    gradient{i} = [];
    if isempty(pps_index_by_qid_set{i})
        continue;
    end
    tic;
    for j = 1:length(label_set)
        v_qid_sameLabel_ik_set = pp_details_qid_set{i,3}{j};
        if isempty(v_qid_sameLabel_ik_set)
            continue;
        end
        % calculate the v_jk index set relateing to v_ik under the same qid
        v_jk_set_qid = GetV_jk_set_by_V_ik(v_qid_sameLabel_ik_set(1),pps_index_by_qid_set{i});
        %pp_ijk_global_index_set = GetPPs_ijk_global_index(pps_index_by_qid_set,i,v_qid_ik);
        % we store GetPPs_ijk_global_index by columns in matrix
        pp_ijk_global_index_matrix = GetPPs_ijk_global_index_matrix(pps_index_by_qid_set,i,v_qid_sameLabel_ik_set);
        %gradient_regular_coeff_vec = A(pp_ijk_global_index_set,:)*(Q*alpha);
        %gradient_regular_coeff_vec = A(pp_ijk_global_index_set,:)*(Q*alpha);
        gradient_regular_coeff_matrix = zeros(size(pp_ijk_global_index_matrix));
%         tic;
        for k = 1:size(pp_ijk_global_index_matrix,2);
            gradient_regular_coeff_matrix(:,k) = A(pp_ijk_global_index_matrix(:,k),:)*(Q*alpha);
        end
%         t1 = toc;
        
        %gradient_regular_qid_ik = gradient_regular_coeff_vec' * V{i}(v_jk_set_qid,:);
        %each row of gradient_regular_matrix stands for gradient_regular component of doc_ik
        gradient_regular_matrix = gradient_regular_coeff_matrix' * V{i}(v_jk_set_qid,:);
        
        gradient_loss_coeff_matrix = zeros(size(pp_ijk_global_index_matrix'));
       %gradient_loss_coeff_matrix2 = zeros(size(pp_ijk_global_index_matrix'));
%         tic;
        for k = 1:size(pp_ijk_global_index_matrix,2);
            tmp2 = A(tmp>0,:)*(Q*A(pp_ijk_global_index_matrix(:,k),:)');
            gradient_loss_coeff_matrix(k,:) = sum(tmp2,1);
        end
%         t2 = toc;
%         tic;
%         we use A(:) to convert matrix into a column vector
%         col_vec =  pp_ijk_global_index_matrix(:);
%         tmp22 = A(tmp>0,:)*(Q*A(pp_ijk_global_index_matrix(:),:)');
%         tmp3 = sum(tmp22,1);
%         [M,N] = size(gradient_loss_coeff_matrix);
%         tmp4 = reshape(tmp3,N,M);        
%         gradient_loss_coeff_matrix = tmp4';        
%         t3 = toc;
        %each row of gradient_loss_matrix stands for gradient_loss component of doc_ik
        gradient_loss_matrix = gradient_loss_coeff_matrix * V{i}(v_jk_set_qid,:);
        gradient_matrix = gradient_regular_matrix - C * gradient_loss_matrix;
        gradient{i}(pp_details_qid_set{i,3}{j},:) = gradient_matrix;
    end
    t4 = toc;
end
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

function pp_ijk_global_index_matrix = GetPPs_ijk_global_index_matrix(pps_index_by_qid_set,qid_index,v_qid_sameLabel_ik_set)
intercept_length = 0;
for i=1:1:(qid_index-1)
    intercept_length = intercept_length + size(pps_index_by_qid_set{i},1);
end
for j = 1:length(v_qid_sameLabel_ik_set)
    v_qid_ik = v_qid_sameLabel_ik_set(j);
    [row3(:,j)]= find(pps_index_by_qid_set{qid_index}(:,5)==v_qid_ik|pps_index_by_qid_set{qid_index}(:,6)==v_qid_ik);
end
pp_ijk_global_index_matrix = row3 + intercept_length;
end

function v_qid_jk_set2 = GetV_jk_set_by_V_ik(v_qid_ik_index,sample_pp_index)
% v_qid_jk_set = [];
if isempty(sample_pp_index)
    return;
end
v_qid_jk_set2 = [sample_pp_index(sample_pp_index(:,5)==v_qid_ik_index,6) ...
    ;sample_pp_index(sample_pp_index(:,6)==v_qid_ik_index,5)];
end
function v_qid_jk_set2 = GetV_jk_set_by_V_ik_set(v_qid_ik_index,sample_pp_index)
% v_qid_jk_set = [];
if isempty(sample_pp_index)
    return;
end
v_qid_jk_set2 = [sample_pp_index(sample_pp_index(:,5)==v_qid_ik_index,6) ...
    ;sample_pp_index(sample_pp_index(:,6)==v_qid_ik_index,5)];
end

function lossFun_value = lossFun_A(Q,A , V_old, C,pps_index_by_qid_set)
%%calculate regular_term
alpha_hat = GetAlpha_by_vMatrix(V_old,pps_index_by_qid_set);

alpha = A'*alpha_hat;
regular_term = alpha' * Q * alpha;
tmp = 1-A*(Q*alpha);
loss_term = sum(tmp(tmp>0));
lossFun_value = 0.5* regular_term + C*loss_term;
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