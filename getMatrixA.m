function A = getMatrixA(pp_details_qid_set,label_set)
query_num = size(pp_details_qid_set,1);
sparse_i = [];
sparse_j = [];
sparse_s = [];
row_index = 0;
sparse_m = 0;
sparse_n = getIntercept_qid(pp_details_qid_set,query_num+1,label_set);    
for i = 1:query_num 
    sparse_m = sparse_m + size(pp_details_qid_set{i,2},1);
    intercept = getIntercept_qid(pp_details_qid_set,i,label_set);    
    for j = 1:size(pp_details_qid_set{i,2},1);
%         if rem(row_index,2) == 0
%             row_index = row_index + 1;
%         end
        row_index = row_index + 1;
        sparse_i = [sparse_i;row_index;row_index];       
        sparse_j = [sparse_j;intercept + pp_details_qid_set{i,2}(j,5); ... 
            intercept + pp_details_qid_set{i,2}(j,6)];
        sparse_s = [sparse_s;1;-1];
    end
end
A = sparse(sparse_i,sparse_j,sparse_s,sparse_m,sparse_n);
end

function intercept = getIntercept_qid(pp_details_qid_set,i,label_set)
doc_num = 0;
for j = 1:i-1
    for k = 1:length(label_set)
        doc_num = doc_num + length(pp_details_qid_set{j,3}{1,k});
    end    
end
intercept = doc_num;
end