function [alpha_new, w, diff ] = rankSVM_A( data_fold_train,data_fold_vali,data_fold_test,sample_pp_fea,...
    alpha_hat,Q,A,C,max_iterate_num,epsilon,original_data_dir,evaluateInput_dir,...
    evaluateOutput_dir,eval_score_perl_file )
%RANKSVM Summary of this function goes here
%   Detailed explanation goes here
w = alpha_hat'*sample_pp_fea;
GetNDCG(num2str(0),w,data_fold_train,data_fold_vali,data_fold_test,...
    original_data_dir,evaluateInput_dir,evaluateOutput_dir,eval_score_perl_file);
tic;
alpha = A'*alpha_hat;
alpha_old = alpha;
alpha_new = alpha_old;%zeros(length(alpha_old),1);
effi = 5;
power = 3;
output_interval = 10;
eta = effi*(10^(-power));
ite_num = 0;
[~,~,old_fun_val] = lossFun_A(Q,A , alpha_old, C);%lossFun(gram_matrix , alpha_old, C);
t2 = toc;
tic;
while 1
    tic;    
    gradient = vec_gradientOfLoss_A(Q,A ,alpha_old , C);
    t1 = toc;
    tic;
    [proper_eta,new_fun_val] = find_eta(Q,A,C,eta,alpha_old,gradient,old_fun_val);
    t2 = toc;
    tic;
    alpha_new = alpha_old - proper_eta * gradient;
    %[~,~,new_fun_val]  = lossFun_A(Q,A , alpha_new, C);%lossFun(gram_matrix , alpha_new, C);
    diff=(old_fun_val-new_fun_val);
    if( diff > epsilon &&ite_num < max_iterate_num)%
        alpha_old = alpha_new;        
        ite_num = ite_num + 1;
        function_val(ite_num,1) = new_fun_val;
        fprintf('ite%d(rankSVM):old_fun_val=%f\tnew_fun_val=%f\tdiff=%f\n',ite_num,old_fun_val,new_fun_val,diff);
        old_fun_val = new_fun_val;
        if diff<200
            eta = proper_eta;
        end
%         if rem(ite_num,50) ==0
%             disp([ite_num,diff,new_fun_val]);
%         end
        if rem(ite_num,output_interval) ==0
            [w,alpha_hat] = getW(A,alpha_new,sample_pp_fea);
            w_file_name =  [evaluateOutput_dir 'w_ite' num2str(ite_num) '.txt'];
            alpha_hat_file_name = [evaluateOutput_dir 'alpha_hat_ite' num2str(ite_num) '.txt'];
            write2file( evaluateOutput_dir,w_file_name,w' );
            write2file( evaluateOutput_dir,alpha_hat_file_name,alpha_hat );
            GetNDCG(num2str(ite_num),w,data_fold_train,data_fold_vali,data_fold_test,...
                original_data_dir,evaluateInput_dir,evaluateOutput_dir,eval_score_perl_file);            
        end
    else
        break;
    end    
end
if rem(ite_num,output_interval) ~=0
    [w,alpha_hat] = getW(A,alpha_new,sample_pp_fea);
    w_file_name =  [evaluateOutput_dir 'w_ite' num2str(ite_num) '.txt'];
    alpha_hat_file_name = [evaluateOutput_dir 'alpha_hat_ite' num2str(ite_num) '.txt'];
    write2file( evaluateOutput_dir,w_file_name,w' );
    write2file( evaluateOutput_dir,alpha_hat_file_name,alpha_hat );
    GetNDCG(num2str(ite_num),w,data_fold_train,data_fold_vali,data_fold_test,...
        original_data_dir,evaluateInput_dir,evaluateOutput_dir,eval_score_perl_file);
end
t1 = toc;
fun_val_file_name =  [evaluateOutput_dir 'fun_val_C_' num2str(C) '.txt'];
 write2file( evaluateOutput_dir,fun_val_file_name,function_val );
w = getW(A,alpha_new,sample_pp_fea);  
end

function [w,alpha_hat_final] = getW(A,alpha_new,sample_pp_fea)
%gmres_A = sparse(A*A')+ sparse(eye(size(A*A'))*10^(-100));
tmp = diag(sparse(A*A'));
gmres_A = sparse(A*A') + diag(tmp*10^(-100));
%gmres_A = sparse(A*A');
gmres_B = A*alpha_new;
alpha_hat_final = gmres(gmres_A,gmres_B);
w = alpha_hat_final'*sample_pp_fea;
end

function [regular_term,loss_term,lossFun_value] = lossFun_A(Q,A , alpha, C)
%alpha = A' * alpha_hat;
regular_term = alpha' * Q * alpha;
tmp = 1-A*(Q*alpha);
loss_term = sum(tmp(tmp>0));
lossFun_value = 0.5* regular_term + C*loss_term;
end

function [proper_eta,new_fun_val] = find_eta(Q,A,C,eta,alpha_old,gradient,old_fun_val)
ite = 50;
while ite>0
    alpha_new = alpha_old - eta * gradient;
    [~,~,new_fun_val]  = lossFun_A(Q,A , alpha_new, C);
    if(new_fun_val<old_fun_val)
        break;
    else
        eta = eta/2;
    end
    ite = ite-1;
end
proper_eta = eta;
end

function gradient = vec_stochastic_gradientOfLoss_A(Q,A,alpha,C)
tic;
gradient_regular = (Q * alpha);
t1 = toc;
% iterate all preference pairs
%sum_pp = (alpha'*gram_matrix);
tic;
tmp = 1-A*gradient_regular;
t2 = toc;
%A_Q = sparse(A*Q);
a = A(tmp>0,:);
gradient_loss = zeros(1,length(alpha));
tic;
divisor = length(a);
divident = length(alpha)*4;
quotient = floor(divisor/divident);
%remain = rem(divisor,divident);
for i = 1:quotient
    j = (i-1)*divident+1:i*divident;
    tmp2 =a(j,:)*Q;
    gradient_loss = gradient_loss + sum(tmp2,1);
end
j = i*divident+1:divisor;
tmp2 =a(j,:)*Q;
gradient_loss = gradient_loss + sum(tmp2,1);
t3 = toc;
%gradient_loss = sum(A_Q(tmp>0,:),1);
gradient = gradient_regular - C * gradient_loss';
end
function gradient = vec_gradientOfLoss_A(Q,A ,alpha , C)
tic;
gradient_regular = (Q * alpha);
t1 = toc;
% iterate all preference pairs
%sum_pp = (alpha'*gram_matrix);
tic;
tmp = 1-A*gradient_regular;
t2 = toc;
%A_Q = sparse(A*Q);
a = A(tmp>0,:);
gradient_loss = zeros(1,length(alpha));
tic;
divisor = length(a);
divident = length(alpha)*4;
quotient = floor(divisor/divident);
%remain = rem(divisor,divident);
for i = 1:quotient
    j = (i-1)*divident+1:i*divident;
    tmp2 =a(j,:)*Q;
    gradient_loss = gradient_loss + sum(tmp2,1);
end
j = i*divident+1:divisor;
tmp2 =a(j,:)*Q;
gradient_loss = gradient_loss + sum(tmp2,1);
t3 = toc;
%gradient_loss = sum(A_Q(tmp>0,:),1);
gradient = gradient_regular - C * gradient_loss';
end
