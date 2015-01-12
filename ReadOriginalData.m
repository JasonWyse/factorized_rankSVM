function [ data_fold1_train,data_fold1_vali,data_fold1_test ] = ReadOriginalData( data_dir,feature_num )
%READORIGINALDATA Summary of this function goes here
%   Detailed explanation goes here
A = exist(data_dir,'dir');
if A==0
    mkdir(data_dir);
end
[ data_fold1_train ] = ReadFileByLine([data_dir 'train.txt'],feature_num);
[ data_fold1_vali ] = ReadFileByLine([data_dir 'vali.txt'],feature_num);
[ data_fold1_test ] = ReadFileByLine([data_dir 'test.txt'],feature_num);
end

