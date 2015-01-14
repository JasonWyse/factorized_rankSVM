function [ data_fold_train,data_fold_vali,data_fold_test,label_set,pp_details_qid_set,qid_set,...
   V, sample_pp_fea,alpha_hat, Q,A ] = PrepareDataForFold( original_data_dir,...
    feature_num,V_col_size)
%PREPAREDATAFORFOLD Summary of this function goes here
% dataset_name = 'MQ2008';
% epsilon = 0.01;
% fold_set = [1,2,3,4,5];
% max_iterate_num = 1;
% feature_num = 45;
% V_col_size = 4;
%   Detailed explanation goes here
[ data_fold_train,data_fold_vali,data_fold_test ] = ReadOriginalData( original_data_dir,feature_num );
%label_set = [2,1,0];
label_set = sort(unique(data_fold_train(:,1)),'descend');
% % show statistic information on the fold
% statistics( data_fold_train );
% %generate all preference pairs according to qid
[pp_details_qid_set ] = GetPreferencePairs_all_qid( data_fold_train,label_set );
%initialize the equivalent matrix V and vector alpha
%qid_set = sort(unique(data_fold_train(:,2)),'ascend');
qid_set = unique(data_fold_train(:,2),'stable');
[ V ,alpha_qid_set ] = GetMatrix_V_Alpha_by_qid_set( data_fold_train,pp_details_qid_set,qid_set,V_col_size );
[ pps_fea_by_qid_set ] = GetPreferencePairsFea_by_qid_set( data_fold_train,pp_details_qid_set,qid_set,feature_num );
% tic;
%[alpha_rankSVM, w_rankSVM,diff_rankSVM ] = rankSVM( pps_fea_by_qid_set,alpha_qid_set, C );
[ data_points_fea_by_qid ] = GetDataPointsFea_by_qid_set( data_fold_train,qid_set,label_set,feature_num );
[ sample_pp_fea,alpha_hat ] = GetPPsFea_by_qid_set( pps_fea_by_qid_set,alpha_qid_set );
Q = getAllDocsKernel(data_points_fea_by_qid,label_set);
A = getMatrixA(pp_details_qid_set,label_set);

end

