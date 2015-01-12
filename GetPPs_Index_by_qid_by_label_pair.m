function [ pps_index_by_qid_by_label_pair ] = GetPPs_Index_by_qid_by_label_pair( data_pp_details_by_qid,qid_set )
%GETPREFERENCEPAIRSINDEX_BY_LABEL_LEVEL Summary of this function goes here
%   Detailed explanation goes here
qid_set = sort(unique(qid_set),'ascend');
qid_all_set = cell2mat(data_pp_details_by_qid(:,1));
[C,IA,IB] = intersect(qid_all_set,qid_set) ;
pps_index_by_qid_by_label_pair = cell(length(qid_set),1);
pps_index_by_qid = data_pp_details_by_qid(IA,2);
label_set_by_qid = data_pp_details_by_qid(IA,3);
for i = 1:length(qid_set)
    label_set_size = length(label_set_by_qid{i});
    k = 1:size(pps_index_by_qid{i},1);
    for j = 1:label_set_size
        current_label_set = label_set_by_qid{i}{j};
        pps_index_by_qid_by_label_pair{i,1}{j,1} = pps_index_by_qid{i}(ismember(pps_index_by_qid{i}(k,2),current_label_set),:);
    end
end
end

