function [alpha_new, w, diff ] = rankSVM( pps_fea_by_qid_set,alpha_qid_set, C,epsilon )
%RANKSVM Summary of this function goes here
%   Detailed explanation goes here
% sample_pp_fea_length = 0;
% for i = 1:length(pps_fea_by_qid_set);
%     sample_pp_fea_length = sample_pp_fea_length + length(pps_fea_by_qid_set{i,1});
% end
sample_pp_fea = [];
for i = 1:length(pps_fea_by_qid_set);
    sample_pp_fea = [sample_pp_fea;pps_fea_by_qid_set{i,1}];
end
alpha = [];
for i = 1:length(alpha_qid_set);
    alpha = [alpha;alpha_qid_set{i,1}];
end
alpha_old = alpha;
alpha_new = zeros(length(alpha_old),1);
%get gram matrix
gram_matrix = sample_pp_fea * sample_pp_fea';
%epsilon = 0.001;
effi = 5;
power = 6;
eta = effi*(10^(-power));
index = 0;
[~,~,old_fun_val] = lossFun(gram_matrix , alpha_old, C);
while 1
    gradient = vec_gradientOfLoss(gram_matrix ,alpha_old , C);
    alpha_new = alpha_old - eta * gradient;
    [~,~,new_fun_val]  = lossFun(gram_matrix , alpha_new, C); 
    diff=old_fun_val-new_fun_val;
    if(diff >epsilon)  
        alpha_old = alpha_new;
        old_fun_val = new_fun_val;
        index = index + 1;
    else
        break; 
    end
end 
w = alpha_new'*sample_pp_fea;
end

function [regular_term,loss_term,lossFun_value] = lossFun(gram_matrix , alpha, C)
regular_term = alpha'*gram_matrix*alpha;
sum_pp = (alpha'*gram_matrix);
tmp = 1-sum_pp;
loss_term = sum(tmp(tmp>0));
lossFun_value = 0.5* regular_term + C*loss_term;
end

function gradient = vec_gradientOfLoss(gram_matrix ,alpha , C)
gradient_regular = (gram_matrix * alpha);
% iterate all preference pairs
tmp = 1-(alpha'*gram_matrix);
gradient_loss = sum(gram_matrix(tmp>0,:),1);
gradient = gradient_regular - C * gradient_loss';
end

function gradient_ijk = gradientOfLoss(gram_matrix ,alpha , C, alpha_index)
pp_size = size(gram_matrix,2);
i = 1:pp_size;
%gradient_regular = dot(alpha(i) , gram_matrix(i,alpha_index));
gradient_regular = (alpha(i)'* gram_matrix(i,alpha_index));
% iterate all preference pairs
i=1:pp_size;
j=1:pp_size;
sum_pp = (alpha(j)'*gram_matrix(j,i));
gradient_loss = sum(gram_matrix(alpha_index,1-sum_pp>0));
gradient_ijk = gradient_regular - C * gradient_loss;
end

% function [regular_term,loss_term,lossFun_value] = lossFun(gram_matrix , alpha, C)
% pp_size = size(gram_matrix,2);
% regular_term = 0;
% loss_term = 0;
% %%calculate regular_term
% for i=1:pp_size
%     for j=1:pp_size;
%     regular_term = regular_term+(alpha(i)*alpha(j)*gram_matrix(i,j));
%     end
% end
% %%%%%%%%%%
% %calculate loss term
% for i=1:pp_size% iterate all preference pairs   
%     j=1:pp_size;
%     sum_pp = dot(alpha(j),gram_matrix(j,i));
%     if(1-sum_pp>0)
%         loss_single_pp = 1-sum_pp;
%         loss_term = loss_term + loss_single_pp;
%     end
% end
% %%%%%%%%%%%
% lossFun_value = 0.5* regular_term + C*loss_term;
% end