%kDD
%total 494021 rows, 41 columns, 7 cat, 34 cont. Many y label , most common
% three are considered anamlous (Normal,Smurf,Neptune):
% (97278,280790,107201) %[20%, 57%, 22%]
%others considered anomalous, only 1.78%

%To give up on correct imports:
addpath(genpath('C:\Users\mbd83\Desktop\Matteson\Projects\AnomalyDetection\CodesClean'));
addpath(genpath('..'));
%data=readtable('C:\Users\mbd83\Desktop\Matteson\Datasets\UCI\kddCup.txt');
data=readtable('..\..\..\..\Datasets\UCI\kddCup.txt');

[nr,~]=size(data);
InlierNames={'normal.','smurf.','neptune.'}; 
yCol=data{:,end};
normalIdx=find(strcmp(yCol,'normal.'));
smurfIdx=find(strcmp(yCol,'smurf.'));
neptuneIdx=find(strcmp(yCol,'neptune.'));
allInlier=[normalIdx;smurfIdx;neptuneIdx];
anomIdx=setdiff(1:nr,allInlier);
qualColIndex=[2,3,4,7,12,21,22];

%embedArray = robustNine(data,qualColIndex);
embedArray = makePaperEmbed(data,qualColIndex);

yesSave = false;
saveName = 'kddRes.mat';
%to run all
origTable= data(:,1:end-1);
%[CR,E,Edet,denseTable,qualColNew]=startTableClean(origTable,qualColIndex,anomIdx,'kdd');
[CR,E,Edet,denseTable,qualColNew]=startTableConfig(origTable,embedArray,qualColIndex,anomIdx,'kdd');
