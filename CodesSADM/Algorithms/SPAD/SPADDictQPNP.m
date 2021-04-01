 function [scores,scoreMatrix] = SPADDictQPNP(train,test,params)
%Performs the SPAD anomaly detection algorithm - basically 
%naive bayes after discretizing data

%params.d: number of bins to discretize continuous columns
%params.nSigma: how to categorize continuous columns

if nargin==0
    data=importdata('mixed_data.csv');
    data=data(2:end,2:end);
    groundTruth=1;
    trueOutliers=[1,3,4,5]; %indexes of ground truth outliers
    d=5;
    nSigma=3;
    train=data;
    test=data;
end

if nargin==2 || numel(fields(params)) == 0
    params=defaultSPAD(train);
end

[nr,nc]=size(train);

nSigma=params.nSigma;
d=params.d;
qualColsIndex=params.qualColsIndex;
quantColsIndex=setdiff((1:nc),qualColsIndex);

[trainDisc,centerBinVals]=trainDiscretizeData(train(:,quantColsIndex),d,nSigma);
trainDiscFull=train;
trainDiscFull(:,quantColsIndex)=trainDisc;
if ~isequal(train,test)
    testDisc=testDiscretizeData(test(:,quantColsIndex),centerBinVals);
    testDiscFull=test;
    testDiscFull(:,quantColsIndex)=testDisc;
else
    testDiscFull=trainDiscFull;
end
[freqTable]=calcFrequencyTableMap(trainDiscFull);
[scores,scoreMatrix]=calcSPADscores(testDiscFull,freqTable);
end

function [discData,centerBinVals]=trainDiscretizeData(data,d,nSigma)

    
[~,nc]=size(data);
centerBinVals=cell(0,1);
for i=1:nc
    curCol=data(:,i);
    curMean=mean(curCol);
    curStd=std(curCol);
    centerBinVals{i}=linspace(curMean-nSigma*curStd,curMean+nSigma*curStd,d);
    centerBinVals{i}=[-inf,centerBinVals{i},inf];
    curCol=discretize(curCol,centerBinVals{i});
    data(:,i)=curCol;
end
discData=data;
end

function[discData]=testDiscretizeData(data,centerBinVals)
[~,nc]=size(data);
for i=1:nc
    curCol=data(:,i);
    curCol=discretize(curCol,centerBinVals{i});
    data(:,i)=curCol;
end
discData=data;
end

function[freqTableMap]=calcFrequencyTableMap(discTrain)
[nr,nc]=size(discTrain);
for c=1:nc
    curCol=discTrain(:,c);
    [curX,ia,ic]=unique(curCol);
    nUni=length(curX);
    posCurX=curX-min(curX)+1;
    initialCount=zeros(numel(curX),1);
    m=zeros(1,max(posCurX));
    curDict=containers.Map(curX,initialCount);
    idx=1;
    for j=1:nUni
        value=length(find(curCol==curX(j)));
        curDict(curX(j))=(value+1)/(nr+nUni); %Laplacian smoothing
        %m(curCol(r)-min(curX)+1)=m(curCol(r)-min(curX)+1)+1/nr;
    end
    %curDict('Unseen')=UnseenValue; %need to specify keys of different
    %types
    freqTableMap{c}=curDict;
end
end

function[scores,scoreMatrix]=calcSPADscores(discTestData,freqTableMap)
[nr,nc]=size(discTestData);
scoreMatrix=zeros(nr,nc);
newCatValue=1/nr;
for c=1:nc
    curDict=freqTableMap{c};
    curKeys=curDict.keys;
    curCol=discTestData(:,c);
    for key=curKeys
        curSet=find(curCol==key{1}); %May not be optimal if many classes
        scoreMatrix(curSet,c)=curDict(key{1});
    end
    newCatSet=find(scoreMatrix(:,c)==0);
    scoreMatrix(newCatSet,c)=newCatValue;   
end
scores=-sum(log(scoreMatrix),2);
end


