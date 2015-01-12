function [ labelPair ] = GetW_by_differentLevelPair_PPs_set( data_fold,data_pp_details_by_qid,qid_set,C )
%GETW_ Summary of this function goes here
%   Detailed explanation goes here
[ pps_index_by_qid_by_label_level ] = GetPPs_Index_by_qid_by_label_pair( data_pp_details_by_qid,qid_set );
pps_fea_by_qid_by_label_pair = GetPreferencePairsFea_by_qid_by_label_pair(data_fold,pps_index_by_qid_by_label_level,qid_set);
pps_fea_by_label_pair = GetPreferencePairsFea_by_label_pair(pps_fea_by_qid_by_label_pair);
alpha_cell = cell(1,length(pps_fea_by_label_pair));
pps_fea_set = cell(1,length(pps_fea_by_label_pair));
for i = 1:length(pps_fea_by_label_pair)
    alpha_cell{i} = rand(length(pps_fea_by_label_pair{i}),1);
    pps_fea_set{i} = pps_fea_by_label_pair{i};
    [labelPair.alpha{i},labelPair.w{i}, labelPair.diff{i}] = rankSVM( pps_fea_set(i),alpha_cell(i), C );
end
end 

function pps_fea_by_label_pair = GetPreferencePairsFea_by_label_pair(pps_fea_by_qid_by_label_pair)
qid_set_size = length(pps_fea_by_qid_by_label_pair);
label_set_size = length(pps_fea_by_qid_by_label_pair{1});
pps_fea_by_label_pair = cell(1,label_set_size);
for i = 1:label_set_size
    pps_fea_by_label_pair{i} = [];
    for j = 1:qid_set_size
        pps_fea_by_label_pair{i} = [pps_fea_by_label_pair{i}; ...
            pps_fea_by_qid_by_label_pair{j}{i}];
    end
end
end

