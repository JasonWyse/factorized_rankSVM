function [ sample ] = ReadFileByLine( fileName,feature_num )
%READFILEBYLINE Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(fileName);

tline = fgetl(fid);
index = 1;
tic;
%sample = zeros(10000,50);
while ischar(tline)
    if(isempty(tline))
        tline = fgetl(fid);
        continue;
    end    
    tline = strtrim(tline);
    S = regexp(tline, '\s', 'split');
    count = length(S);
    col_index = 0;
    for i=1:count
        S_i = regexp(S{1,i}, ':', 'split');
        tem = str2double(S_i(end));
        if(~isempty(tem)&&~isnan(tem))
            col_index = col_index + 1;
            sample(index,col_index) = tem;            
        end
    end
    index = index + 1;
    tline = fgetl(fid);
end
t1 = toc;
%sample = [sample(:,1:2),sample(:,end),sample(:,3:end-1)];
sample = sample(:,1:2+feature_num);
fclose(fid);

end

