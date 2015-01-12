function Q = getAllDocsKernel(data_points_fea_by_qid,label_set)
query_num = length(data_points_fea_by_qid);
allDocsFea = [];
for i = 1:query_num
    for j = 1:length(label_set)
        allDocsFea = [allDocsFea;data_points_fea_by_qid{i,1}{1,j}];
    end
end
Q = allDocsFea * allDocsFea';
end