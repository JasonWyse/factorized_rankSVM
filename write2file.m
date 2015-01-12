function [ output_args ] = write2file( file_dir,file_name,variable )
%WRITE2FILE Summary of this function goes here
%   Detailed explanation goes here
A = exist(file_dir,'dir');
if A==0
    mkdir(file_dir);
end
c = fopen(file_name,'w');
fprintf(c,'%f\n',variable);
fclose(c);
end

