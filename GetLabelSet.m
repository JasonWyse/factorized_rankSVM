function [ label_set ] = GetLabelSet( data_fold_label_set )
%GETLABELSET Summary of this function goes here
%   Detailed explanation goes here
label_set = sort(unique(data_fold_label_set),'descend');
end

