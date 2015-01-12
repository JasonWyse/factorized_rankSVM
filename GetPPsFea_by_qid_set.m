function [ sample_pp_fea,alpha_hat ] = GetPPsFea_by_qid_set( pps_fea_by_qid_set,alpha_qid_set )
%GETPPS_FEA_BY_QID_SET Summary of this function goes here
%   Detailed explanation goes here
sample_pp_fea = [];
for i = 1:length(pps_fea_by_qid_set);
    sample_pp_fea = [sample_pp_fea;pps_fea_by_qid_set{i,1}];
end

alpha_hat = [];
for i = 1:length(alpha_qid_set);
    alpha_hat = [alpha_hat;alpha_qid_set{i,1}];
end

end

