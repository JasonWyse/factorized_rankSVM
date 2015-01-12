function [ pps_fea_by_qid_by_label_pair ] = GetPreferencePairsFea_by_qid_by_label_pair( data_fold,pps_index_by_qid_by_label_level,qid_set )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
qid_set_size = length(qid_set);
label_set_size = length(pps_index_by_qid_by_label_level{1});
pps_fea_by_qid_by_label_pair = cell(qid_set_size,1);
for i = 1:qid_set_size
    qid = qid_set(i);
    data_fold_fea_qid = data_fold(data_fold(:,2)==qid,4:48);
    for j = 1:label_set_size
        index_set = pps_index_by_qid_by_label_level{i}{j};
        k = 1:length(index_set);
%         tmp1 = data_fold_fea_qid(index_set(k,2) ,:);
%         tmp2 = data_fold_fea_qid( index_set(k,3),:);
        pps_fea_by_qid_by_label_pair{i,1}{j} = data_fold_fea_qid(index_set(k,2) ,:) - data_fold_fea_qid( index_set(k,3),:);
    end
end

end

