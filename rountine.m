% original_data_dir = 'data/OHSUMED/Fold1/';
% eval_score_perl_file = 'eval-score-mslr-3.0.pl ';
% V_col_size = 4;
% C = 10;
% epsilon = 0.01;
% max_iterate_num = 100;
% feature_num = 45;
% eval_score_perl_file = 'eval-score-mslr-4.0.pl ';
dataset_name = 'MQ2008';
if(regexpi(dataset_name,'MQ.*'))
    eval_score_perl_file = 'eval-score-mslr-4.0.pl ';
else
    eval_score_perl_file = 'eval-score-mslr-3.0.pl ';
end
 epsilon = 0.01;
 fold_set = [1,2];
 max_iterate_num = 1;
 feature_num = 45;
 V_col_size = 4;
for i = -5:1:5
    C_set(i+6,1) = 10^(i);
end
for i = 1:length(fold_set)
    original_data_dir = ['data/' dataset_name '/Fold' num2str(fold_set(i)) '/'];
    [ data_fold_train,data_fold_vali,data_fold_test,label_set,pp_details_qid_set,qid_set,...
    V, sample_pp_fea,alpha_hat, Q,A ] = PrepareDataForFold( original_data_dir,...
    feature_num,V_col_size);
    for j=1:length(C_set)
        fold_process( original_data_dir,eval_score_perl_file,C_set(j),epsilon, max_iterate_num,...
        data_fold_train,data_fold_vali,data_fold_test,label_set,pp_details_qid_set,...
        V, sample_pp_fea,alpha_hat, Q,A);
    end
end
