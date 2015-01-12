function GetNDCG(ite_num,w,data_fold_train,data_fold_vali,data_fold_test,...
    original_data_dir,evaluateInput_dir,evaluateOutput_dir,eval_score_perl_file)
allDocsScores_train = data_fold_train(:,3:end)*w';
allDocsScores_vali = data_fold_vali(:,3:end)*w';
allDocsScores_test = data_fold_test(:,3:end)*w';
%prediction_file used for perl script
scoreFile_train = [evaluateInput_dir 'docsScore_train_ite' (ite_num) '.txt'];
scoreFile_vali = [evaluateInput_dir 'docsScore_vali_ite' (ite_num) '.txt'];
scoreFile_test = [evaluateInput_dir 'docsScore_test_ite' (ite_num) '.txt'];
%write the matlab variable into text file,get ready for perl command
write2file(evaluateInput_dir,scoreFile_train,allDocsScores_train);
write2file(evaluateInput_dir,scoreFile_vali,allDocsScores_vali);
write2file(evaluateInput_dir,scoreFile_test,allDocsScores_test);

perl_script = eval_score_perl_file;
if(exist(evaluateOutput_dir,'dir')==0)
    mkdir(evaluateOutput_dir);
end
%to generate the NDCG on train set
feature_file = [original_data_dir 'train.txt '];
prediction_file = [scoreFile_train ' '];
result_file = [evaluateOutput_dir 'NDCG_train_ite' ite_num '.txt '];
flag = '0';
cmd = ['perl ' perl_script feature_file prediction_file result_file flag];
system(cmd);
%to generate the NDCG on vali set
feature_file = [original_data_dir 'vali.txt '];
prediction_file = [scoreFile_vali ' '];
result_file = [evaluateOutput_dir 'NDCG_vali_ite' ite_num '.txt '];
flag = '0';
cmd = ['perl ' perl_script feature_file prediction_file result_file flag];
system(cmd);
%to generate the NDCG on test set
feature_file = [original_data_dir 'test.txt '];
prediction_file = [scoreFile_test ' '];
result_file = [evaluateOutput_dir 'NDCG_test_ite' ite_num '.txt '];
flag = '0';
cmd = ['perl ' perl_script feature_file prediction_file result_file flag];
system(cmd);
end