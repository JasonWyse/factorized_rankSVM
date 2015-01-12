function [ output_args ] = fold_process( original_data_dir,eval_score_perl_file,V_col_size,C, epsilon, max_iterate_num,feature_num)
% %read file data into workspace

% original_data_dir = 'data/OHSUMED/Fold1/';
% V_col_size = 4;
% C = 0.1;
% epsilon = 0.01;
% max_iterate_num = 100;
% feature_num = 45;
[ data_fold_train,data_fold_vali,data_fold_test ] = ReadOriginalData( original_data_dir,45 );
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

[ evaluateInput_dir,evaluateOutput_dir ] = GetEvaluateDir( original_data_dir ,'rankSVM',C);
[alpha_hat_rankSVM, w, diff ] = rankSVM_A( data_fold_train,data_fold_vali,data_fold_test,...
    sample_pp_fea,alpha_hat,Q,A,C,max_iterate_num ,epsilon,original_data_dir,...
    evaluateInput_dir,evaluateOutput_dir,eval_score_perl_file );

 % t1 = toc;
% tic;
%[ alpha_fac, w_fac, diff_fac ] = rankSVM_fac(  pps_fea_by_qid_set,pp_details_by_qid,qid_set,V, C);

[ evaluateInput_dir,evaluateOutput_dir ] = GetEvaluateDir( original_data_dir ,'rankSVM_fac',C);
[ alpha_hat_fac, w_fac, function_val_fac ] = rankSVM_fac_A( label_set,pp_details_qid_set, data_fold_train,data_fold_vali,data_fold_test,sample_pp_fea,...
    Q,A,C,max_iterate_num,V,epsilon,original_data_dir,evaluateInput_dir,evaluateOutput_dir,eval_score_perl_file);

end

