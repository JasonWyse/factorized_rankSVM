% %read file data into workspace

original_data_dir = 'data/OHSUMED/Fold4/';
V_col_size = 4;
C = 0.1;
epsilon = 0.01;
max_iterate_num = 100;
feature_num = 45;
% evaluateInput_dir = 'EvaluateInput/OHSUMED/rankSVM/Fold2/';
% evaluateOutput_dir = 'EvaluateOutput/OHSUMED/rankSVM/Fold2/';
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
% 
[ pps_fea_by_qid_set ] = GetPreferencePairsFea_by_qid_set( data_fold_train,pp_details_qid_set,qid_set,feature_num );
% tic;
%[alpha_rankSVM, w_rankSVM,diff_rankSVM ] = rankSVM( pps_fea_by_qid_set,alpha_qid_set, C );
[ data_points_fea_by_qid ] = GetDataPointsFea_by_qid_set( data_fold_train,qid_set,label_set );

[ sample_pp_fea,alpha_hat ] = GetPPsFea_by_qid_set( pps_fea_by_qid_set,alpha_qid_set );
Q = getAllDocsKernel(data_points_fea_by_qid,label_set);
A = getMatrixA(pp_details_qid_set,label_set);
%[alpha_hat_final, w_rankSVM_A, diff ] = rankSVM_A( data_points_fea_by_qid,pps_fea_by_qid_set,... 
%pp_details_qid_set,alpha_qid_set,label_set ,C ,epsilon );
%[alpha_hat_final, w, diff ] = rankSVM_A( sample_pp_fea,alpha_hat,Q,A,C ,epsilon );
[ evaluateInput_dir,evaluateOutput_dir ] = GetEvaluateDir( original_data_dir ,'rankSVM');
[alpha_hat_rankSVM, w, diff ] = rankSVM_A( data_fold_train,data_fold_vali,data_fold_test,...
    sample_pp_fea,alpha_hat,Q,A,C ,epsilon,original_data_dir,evaluateInput_dir,evaluateOutput_dir );

 % t1 = toc;
% tic;
%[ alpha_fac, w_fac, diff_fac ] = rankSVM_fac(  pps_fea_by_qid_set,pp_details_by_qid,qid_set,V, C);
% evaluateInput_dir = 'EvaluateInput/OHSUMED/rankSVM_fac/Fold2/';
% evaluateOutput_dir = 'EvaluateOutput/OHSUMED/rankSVM_fac/Fold2/';
[ evaluateInput_dir,evaluateOutput_dir ] = GetEvaluateDir( original_data_dir ,'rankSVM_fac');
[ alpha_hat_fac, w_fac, diff ] = rankSVM_fac_A( label_set,pp_details_qid_set, data_fold_train,data_fold_vali,data_fold_test,sample_pp_fea,...
    Q,A,C,V,epsilon,original_data_dir,evaluateInput_dir,evaluateOutput_dir);
% t2 = toc;
% tic;
% [ labelPair ] = GetW_by_differentLevelPair_PPs_set( data_fold_train,data_pp_details_by_qid,qid_set,C );
% t3 = toc;
% [ mergedW_from_labelPair ] = MergeW_from_labelPair_struct( labelPair.w );
% GetDataPointsFea_by_qid_set() to get the data points we want to draw
% qid_set = [31;61];
% [ data_points_fea_by_qid ] = GetDataPointsFea_by_qid_set( data_fold_train,qid_set );
%draw picture;
% statistic_caseStudy_figures( data_points_fea_by_qid,mergedW_from_labelPair,w_rankSVM,w_fac );
% w_cell{1} = w_rankSVM;w_cell{2} = w_fac;
% label_set_by_qid = data_pp_details_by_qid(qid_set,3);
% [ PairWyse_accuracy_distribution ] = PairWyse_accuracy( pps_fea_by_qid_set,label_set_by_qid,w_cell);
