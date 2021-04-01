% testing comprex 

data1=readtable('annTest.txt');
data2=readtable('annTrain.txt');
data=[data1;data2];
xData = data(:,1:end-2); 
yCol = data{:,end};
anomIdx=[find(yCol==1);find(yCol==2)];

qualCols=[2:16];

tableFill=fillMissing2(xData,qualCols);
[denseEncode,~,qualCols]=makeDense(tableFill,qualCols);
[dataMat,~,qualCols]=removeZeroVar(denseEncode,qualCols);

params.d = 10;
params.isavg = true;
params.qualColsIndex = qualCols;
postdata = mattBuildFeatureMatrix(dataMat,params);

 [cost, CT] =  buildModelVar (postdata, params);
%load('CT-save'); %loads CT

[scores] = computeCompressionScoresVar( postdata, CT );
[curROC,curROCCurve]=computeROC4(scores,anomIdx);