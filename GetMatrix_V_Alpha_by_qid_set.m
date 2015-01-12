function [ V ,alpha ] = GetMatrix_V_Alpha_by_qid_set( data_fold,pp_details_qid_set,qid_set,V_col_size )
%GETMATRIX_V_BY_QID_SET Summary of this function goes here
%   Detailed explanation goes here
V = cell(length(qid_set),1);
for i=1:length(qid_set)
    qid = qid_set(i);
    V_subLength_qid = length(data_fold(data_fold(:,2)==qid,2));
    V{i,1} = rand(V_subLength_qid,V_col_size);    
end
%V = rand(V_length,V_col_size);
alpha = GetAlpha_by_vMatrix(V,qid_set,pp_details_qid_set);
end

function alpha = GetAlpha_by_vMatrix(V,qid_set,data_pp_details_by_qid)
qid_all_set = cell2mat(data_pp_details_by_qid(:,1));
alpha = cell(length(qid_set),1);
for i = 1:length(qid_set)
    qid = qid_set(i);
    pps_qid = data_pp_details_by_qid{qid == qid_all_set,2};
    if isempty(pps_qid)
        continue;
    end
    j = 1:size(pps_qid,1);
    alpha{i,1}(j,1) = sum(V{i}(pps_qid(j,5),:).*V{i}(pps_qid(j,6),:),2);
%     if i==600
%         disp(i);
%     end
end
end

