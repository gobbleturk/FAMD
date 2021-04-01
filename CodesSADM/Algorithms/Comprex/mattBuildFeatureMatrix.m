function postdata = mattBuildFeatureMatrix(mixedMat,params)
% mixedMat is a nr x cc feature matrix, some continuous and some cat features
% qualCols describe the qualitative/categorical features, i.e
% qualCols = [2,3,5]
% params.d = numbins

numbins = params.d;
qualCols = params.qualColsIndex;
[nr,nc] = size(mixedMat);
quantCols = setdiff(1:nc,qualCols);

discMat = mixedMat; % to initialize to correct size and copy cat columns

for quantCol = quantCols
    discMat(:,quantCol) = linbin(mixedMat(:,quantCol), numbins);
end

postdata = featurepost(discMat);

%dlmwrite(strcat(filename,'_',num2str(numbins),'linbins.txt'), postdata,'delimiter',' ');
end

function data = featurepost(data)
    for k=2:size(data,2)
        data(:,k) = max(data(:,k-1))+data(:,k); 
    end	
end