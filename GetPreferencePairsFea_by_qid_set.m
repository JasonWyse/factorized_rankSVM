function [ pps_fea_by_qid_set ] = GetPreferencePairsFea_by_qid_set( data_fold,data_pp_details_all_qid,qid_set,feature_num )
%GETPPFEATURES_QID Summary of this function goes here
%   Detailed explanation goes here
% qid_set = sort(unique(qid_set),'ascend');
% qid_all_set = cell2mat(data_pp_details_by_qid(:,1));
%  [C,IA,IB] = intersect(qid_all_set,qid_set) ;
% %a = find(qid_all_set == qid_set);
% pps_index_by_qid = data_pp_details_by_qid(IA,2);
%pps_index_by_qid_set  = GetPreferencePairsIndex_by_qid_set( data_pp_details_all_qid,qid_set );
 qid_all_set = cell2mat(data_pp_details_all_qid(:,1));
%  [C,IA,IB] = intersect(qid_all_set,qid_set) ;
% pps_index_by_qid_set = data_pp_details_all_qid(IA,2);
%pps_index_by_qid_set = data_pp_details_all_qid();
for i=1:length(qid_set)
    qid = qid_set(i);
    pps_index_by_qid_set{i,1} = data_pp_details_all_qid{qid_all_set(:,1)==qid,2};
end
for i = 1:length(pps_index_by_qid_set)
    pps_index_qid = pps_index_by_qid_set{i};
    if isempty(pps_index_qid)
        continue;
    end
    qid = qid_set(i);
    data_fold_fea_qid = data_fold(data_fold(:,2)==qid,3:2+feature_num);       
    j = 1:size(pps_index_qid,1);
    pps_fea_by_qid_set{i,1}(j,:) = data_fold_fea_qid(pps_index_qid(j,5),:) ...
        -data_fold_fea_qid(pps_index_qid(j,6),:);    
end
end

