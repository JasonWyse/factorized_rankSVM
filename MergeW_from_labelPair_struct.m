function [ mergedW_from_labelPair ] = MergeW_from_labelPair_struct( labelPair_w )
%MERGEW_FROM_LABELPAIR_STRUCT Summary of this function goes here
%   Detailed explanation goes here
for i = 1:length(labelPair_w)
   mergedW_from_labelPair(i,:) = labelPair_w{i};
end
end

