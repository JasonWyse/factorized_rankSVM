function [ pps_index_by_qid ] = GetPreferencePairsIndex_by_qid_set( data_pp_details_by_qid,qid_set )
%GETPREFERENCEPAIRSINDEX_BY_QID_SET Summary of this function goes here
%   Detailed explanation goes here
qid_set = sort(unique(qid_set),'ascend');
qid_all_set = cell2mat(data_pp_details_by_qid(:,1));
 [C,IA,IB] = intersect(qid_all_set,qid_set) ;
%a = find(qid_all_set == qid_set);
pps_index_by_qid = data_pp_details_by_qid(IA,2);

end

