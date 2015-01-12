function [ evaluateInput_dir,evaluateOutput_dir ] = GetEvaluateDir( original_data_dir ,method_name,C)
%GETEVALUATEDIR Summary of this function goes here
%   Detailed explanation goes here
% evaluateInput_dir = 'EvaluateInput/OHSUMED/rankSVM/Fold2/';
% evaluateOutput_dir = 'EvaluateOutput/OHSUMED/rankSVM/Fold2/';
S = regexp(original_data_dir, '\/', 'split');
evaluateInput_dir = ['EvaluateInput/' S{1,2} '/' method_name '/' S{1,3} '/' num2str(C) '/'];
evaluateOutput_dir = ['EvaluateOutput/' S{1,2} '/' method_name '/' S{1,3} '/' num2str(C) '/'];
end

