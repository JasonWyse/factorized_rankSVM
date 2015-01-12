function [ qid,pp_labelPairs_by_qid,docs_sortedByLabel ] = GetPreferencePairs_qid( data_fold,qid,label_set )
%GETPREFERENCEPAIRS_QID Summary of this function goes here
% this function is mainly called by GetPreferencePairs_all_qid(),in order
% to generate variable data_pp_details_by_qid
%   Detailed explanation goes here
data_by_qid = data_fold(:,2) == qid;
%label_set = sort(unique(data_fold(data_by_qid,1)),'descend');
for j=1:length(label_set)
    %data_fold's column 1 stands for label value
    %docs_sortedByLabel_by_qid{j} = find(data_fold(data_by_qid,1) == label_set(j));
    docs_sortedByLabel{j} = find(data_fold(data_by_qid,1) == label_set(j));
end
%get all preference pairs for each qid
pp_index = [];
acumulate_index = 0;
for j = 1:length(label_set)-1
    for k =j+1:length(label_set)
        %in 'data_qid_label' variable, docs have been sorted by label
        %value descending
        [tmp,index_increase] = GetPreferencePairs(docs_sortedByLabel ,label_set,j, k,acumulate_index);
        pp_index = [pp_index;tmp];
        acumulate_index = acumulate_index + index_increase;
    end
end
qid_col(1:size(pp_index,1),1) = qid;
pp_labelPairs_by_qid = [qid_col, pp_index];
end

function [qid_pp_index,index] = GetPreferencePairs(docs_sortedByLabel ,label_set,high_label_index, low_label_index,acumulate_index)
% parameter variable docs_sortedByLabel{index} is a logical variable
if high_label_index == low_label_index
    return;
end
%     num_high_label_docs = length(docs_sortedByLabel_by_qid{high_label});
%     num_low_label_docs = length(docs_sortedByLabel_by_qid{low_label});
num_high_label_docs = length(docs_sortedByLabel{high_label_index});
num_low_label_docs = length(docs_sortedByLabel{low_label_index});
index = 0;
qid_pp_index = zeros(num_high_label_docs*num_low_label_docs,3);
for i=1:num_high_label_docs
    for j=1:num_low_label_docs
        index = index + 1;
        qid_pp_index(index,1) = index + acumulate_index;
        qid_pp_index(index,2) = label_set(high_label_index);
        qid_pp_index(index,3) = label_set(low_label_index);
        qid_pp_index(index,4) = docs_sortedByLabel{high_label_index}(i);
        qid_pp_index(index,5) = docs_sortedByLabel{low_label_index}(j);      
       
    end
end
end

