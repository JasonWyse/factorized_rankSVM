function [ alpha, w_fac, diff ] = rankSVM_fac(  pps_fea_by_qid_set,data_pp_details_all_qid,qid_set,V, C)
%RANKSVM_FAC Summary of this function goes here
%   Detailed explanation goes here
pps_index_by_qid_set  = GetPreferencePairsIndex_by_qid_set( data_pp_details_all_qid,qid_set );

sample_pp_fea = [];
for i = 1:length(pps_fea_by_qid_set);
    sample_pp_fea = [sample_pp_fea;pps_fea_by_qid_set{i,1}];
end
%sample_pp_index_cell = data_pp_details_by_qid{}; 
gram_matrix = sample_pp_fea * sample_pp_fea';
epsilon = 0.001;
effi = 5;
power = 6;
eta = effi*(10^(-power));
index = 0;
V_old = V;
V_new = V;
old_fun_val = lossFun(gram_matrix ,pps_index_by_qid_set, V_old, C);
while 1    
    tic;
    gradient = vec_gradientOfLoss(gram_matrix ,pps_index_by_qid_set, V_old, C);
    t1 = toc;
    V_new = updateV_with_gradient(V_old, gradient,eta);
    new_fun_val = lossFun(gram_matrix ,pps_index_by_qid_set, V_new, C);
    diff = old_fun_val-new_fun_val;
    if(abs(old_fun_val-new_fun_val)>epsilon)
        V_old = V_new;
        index = index + 1;
        old_fun_val = new_fun_val;
    else
        break;
    end
end
alpha_cell = GetAlpha_by_vMatrix(V_new,pps_index_by_qid_set); 
alpha = [];
for i = 1:length(alpha_cell)
    alpha = [alpha;alpha_cell{i}];
end
w_fac = alpha'*sample_pp_fea;
end

function V_new = updateV_with_gradient(V_old, gradient,eta)
V_new = V_old;
for i = 1:length(V_old)
    V_new{i} = V_old{i} - eta*gradient{i};
end
end

function gradient = vec_gradientOfLoss(gram_matrix ,sample_pp_index_cell, V, C)
gradient = V;
alpha_cell = GetAlpha_by_vMatrix(V,sample_pp_index_cell);
alpha = [];
for i = 1:length(alpha_cell)
    alpha = [alpha;alpha_cell{i}];
end
%we use i to iterate qid
for i = 1:length(V)    
    for v_qid_ik = 1:size(V{i},1)        
        % calculate the v_jk index set relateing to v_ik under the same qid
        v_jk_set_qid = GetV_jk_set_by_V_ik(v_qid_ik,sample_pp_index_cell{i});
        pp_ijk_global_index_set = GetPPs_ijk_global_index(sample_pp_index_cell,i,v_qid_ik);
        gradient_regular_coeff_vec = alpha'*gram_matrix(:,pp_ijk_global_index_set);
        gradient_regular_qid_ik = gradient_regular_coeff_vec * V{i}(v_jk_set_qid,:);
        sum_pp = (alpha'*gram_matrix);
        %cols variable stores the uvq set        
        [~,uvq_cols] = find(sum_pp(1-sum_pp>0));
        gram_matrix_ijk_uvq = gram_matrix(pp_ijk_global_index_set,uvq_cols);
        gradient_loss_coeff_vec = sum(gram_matrix_ijk_uvq,2);
        gradient_loss_qid_ik =  gradient_loss_coeff_vec' * V{i}(v_jk_set_qid,:);
        gradient_qid_ik_vec = gradient_regular_qid_ik - C * gradient_loss_qid_ik;
        gradient{i}(v_qid_ik,:) = gradient_qid_ik_vec;
    end
end
end

function pp_ijk_global_index = GetPPs_ijk_global_index(sample_pp_index_cell,qid_index,v_qid_ik)
intercept_length = 0;
for i=1:1:(qid_index-1)
    intercept_length = intercept_length + size(sample_pp_index_cell{i},1);
end
% [row1]= find(sample_pp_index_cell{qid_index}(:,5)==v_qid_ik);
% [row2]= find(sample_pp_index_cell{qid_index}(:,6)==v_qid_ik);
[row3]= find(sample_pp_index_cell{qid_index}(:,5)==v_qid_ik|sample_pp_index_cell{qid_index}(:,6)==v_qid_ik);
pp_ijk_global_index = row3 + intercept_length;
end

function v_qid_jk_set2 = GetV_jk_set_by_V_ik(v_qid_ik_index,sample_pp_index)
% v_qid_jk_set = [];
% v_qid_jk_set = [v_qid_jk_set;sample_pp_index(sample_pp_index(:,5)==v_qid_ik_index,6)];
% v_qid_jk_set = [v_qid_jk_set;sample_pp_index(sample_pp_index(:,6)==v_qid_ik_index,5)];
v_qid_jk_set2 = [sample_pp_index(sample_pp_index(:,5)==v_qid_ik_index,6) ...
    ;sample_pp_index(sample_pp_index(:,6)==v_qid_ik_index,5)];
end

function lossFun_value = lossFun(gram_matrix ,sample_pp_index_cell, V, C)
%%calculate regular_term
alpha_cell = GetAlpha_by_vMatrix(V,sample_pp_index_cell);
alpha = [];
for i = 1:length(alpha_cell)
    alpha = [alpha;alpha_cell{i}];
end
regular_term = alpha'*gram_matrix*alpha;
sum_pp = (alpha'*gram_matrix);
tmp = 1-sum_pp;
loss_term = sum(tmp(tmp>0));
lossFun_value = 0.5* regular_term + C*loss_term;
end

function alpha = GetAlpha_by_vMatrix(V,sample_pp_index_cell)
alpha = cell(length(sample_pp_index_cell),1);
for i = 1:length(sample_pp_index_cell)    
    pps_qid = sample_pp_index_cell{i,1};
    j = 1:length(pps_qid);
    alpha{i,1}(j,1) = sum(V{i}(pps_qid(j,5),:).*V{i}(pps_qid(j,6),:),2);
end
end

% function effi = ragular_effi(gram_matrix, V, sample_pp_index, index)
% effi = 0;
% for i=1:size(sample_pp_index,1)
%     v_i1 = sample_pp_index(i,1);
%     v_i2 = sample_pp_index(i,2);
%     effi = effi + dot(V(v_i1,:),V(v_i2,:))*gram_matrix(i,index);
% end
% end

% function gradient_v_ik = gradientOfLoss(gram_matrix ,V , C, sample_pp_index, v_index)
% pp_size = size(gram_matrix,1);
% gradient_regular_v = zeros(1,size(V,2)) ;
% for i = 1:pp_size%iterate all pps, find the pp containing v_index
%     if(sample_pp_index(i,1)==v_index)
%         effi = ragular_effi(gram_matrix, V, sample_pp_index, i);
%         gradient_regular_v = gradient_regular_v + effi*V(sample_pp_index(i,2),:);
%     elseif(sample_pp_index(i,2)==v_index)
%         effi = ragular_effi(gram_matrix, V, sample_pp_index, i);
%         gradient_regular_v = gradient_regular_v + effi*V(sample_pp_index(i,1),:);
%         
%     end
% end
% gradient_loss_v = zeros(1,size(V,2)) ;
% for i=1:pp_size% iterate all preference pairs
%     sum = 0;
%     for j=1:pp_size% calculate loss for each pp
%         v_j1 = sample_pp_index(j,1);
%         v_j2 = sample_pp_index(j,2);
%         sum = sum + dot(V(v_j1,:),V(v_j2,:))*gram_matrix(j,i);
%     end
%     if(1-sum>0)
%         for i2 = 1:pp_size%iterate all pps, find the pp containing v_index
%             if(sample_pp_index(i2,1)==v_index)
%                 gradient_loss_v = gradient_loss_v + gram_matrix(i2,i)*V(sample_pp_index(i2,2),:);
%             elseif(sample_pp_index(i2,2)==v_index)
%                 gradient_loss_v = gradient_loss_v + gram_matrix(i2,i)*V(sample_pp_index(i2,1),:);
%             end
%         end
%     end
% end
% gradient_v_ik = gradient_regular_v - C * gradient_loss_v;
% end


% function lossFun_value = lossFun(gram_matrix ,sample_pp_index, V, C)
% pp_size = size(sample_pp_index,1);
% regular_term = 0;
% loss_term = 0;
% %%calculate regular_term
% for i=1:pp_size
%     for j=1:pp_size
%         v_i1 = sample_pp_index(i,1);
%         v_i2 = sample_pp_index(i,2);
%         v_j1 = sample_pp_index(j,1);
%         v_j2 = sample_pp_index(j,2);
%         regular_term = regular_term + dot(V(v_i1,:),V(v_i2,:))*dot(V(v_j1,:),V(v_j2,:))*gram_matrix(i,j);
%     end
% end
% %%%%%%%%%%
% %calculate loss term
% for i=1:pp_size% iterate all preference pairs
%     sum = 0;
%     for j=1:pp_size% calculate loss for each pp
%         v_j1 = sample_pp_index(j,1);
%         v_j2 = sample_pp_index(j,2);
%         sum = sum + dot(V(v_j1,:),V(v_j2,:))*gram_matrix(j,i);
%     end
%     if(1-sum>0)
%         loss_single_pp = 1-sum;
%         loss_term = loss_term + loss_single_pp;
%     end
% end
% %%%%%%%%%%%
% lossFun_value = 0.5* regular_term + C*loss_term;
% end
