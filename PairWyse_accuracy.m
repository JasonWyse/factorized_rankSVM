function [ tmp ] = PairWyse_accuracy( pps_fea_by_qid_set,label_set_by_qid,w_cell)
%PAIRWYSE_ACCURACY Summary of this function goes here
%   Detailed explanation goes here
for a = 1:length(w_cell)
    for i = 1:length(pps_fea_by_qid_set)
        result = pps_fea_by_qid_set{i,1} * w_cell{1,a}'>0;
        label_set_size = length(label_set_by_qid{i});
        acumulated_index = 0;
        m = 0;
        for j = 1:label_set_size-1
            for k = j+1:label_set_size
                index = 1:length(label_set_by_qid{i}{j})*length(label_set_by_qid{i}{k});
                index = acumulated_index + index;
                m = m + 1;
                tmp{a}{i,1}{m} = sum(result(index,:));
                acumulated_index = acumulated_index + length(label_set_by_qid{i}{j})*length(label_set_by_qid{i}{k});
            end
        end
        
    end
end
end

