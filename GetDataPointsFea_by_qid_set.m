function [ data_points_fea_by_qid ] = GetDataPointsFea_by_qid_set( data_fold,qid_set,label_set,feature_num )
%GET Summary of this function goes here
%   Detailed explanation goes here
data_points_fea_by_qid = cell(length(qid_set),1);
for i = 1:length(qid_set)
    qid = qid_set(i);
    data_fold_by_qid = data_fold(data_fold(:,2)==qid,:);
%     label_set = sort(unique(data_fold_by_qid(:,1)),'descend');
    for j = 1:length(label_set)
        data_points_fea_by_qid{i,1}{j} = data_fold_by_qid( ... 
            data_fold_by_qid(:,1)==label_set(j),3:2+feature_num);
    end
end
end

