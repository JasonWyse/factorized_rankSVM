function [pp_details_by_qid ] = GetPreferencePairs_all_qid( data_fold,label_set )
%GETPREFERENCEPAIRS_ALL_QID Summary of this function goes here
%   Detailed explanation goes here
qid_set = unique(data_fold(:,2),'stable');
pp_details_by_qid = cell(length(qid_set),2);
for i=1:size(qid_set)    
    [pp_details_by_qid{i,1},pp_details_by_qid{i,2},pp_details_by_qid{i,3}] = GetPreferencePairs_qid( data_fold,qid_set(i),label_set );
    
end

end

