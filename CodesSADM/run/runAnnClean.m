%annthyroid
%split into train(3772)
%and test(3428)
%total 7200 rows, 21 columns, 15 cat, 6 cont. 3 classes, two smaller
%considered anomalous (7.4 anom percent)
%reads both files and concatenates


addpath(genpath('..'));

data1=readtable('annTest.txt');
data2=readtable('annTrain.txt');
data=[data1;data2];
yCol = data{:,end};
anomIdx=[find(yCol==1);find(yCol==2)];

qualColIndex=[2:16];
embedArray = makePaperEmbed(data,qualColIndex);
[CR,E,Edet,denseTable,qualColNew]=startTableConfig(data(:,1:end-2),embedArray,qualColIndex,anomIdx,'ann');
