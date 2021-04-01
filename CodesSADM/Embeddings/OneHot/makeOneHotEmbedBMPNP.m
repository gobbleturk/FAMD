function [oneHot,N] = makeOneHotEmbedBMPNP(dataTable,Params)
%Params.rescale = 'FAMD' : rescale according to FAMD
%Params.rescale = 'wFAMD' : rescale according to wFAMD (kurtosis weighted)
%Params.rescale = 'None' or rescale is not a field: no rescaling of OH

%the second output is a placeholder - poorly coded tbh
[nr,nc]=size(dataTable);
if nargin==1
    Params=oneHotEmbedDefault(dataTable);
end
qualColsIndex=Params.qualColsIndex;


if ~isempty(qualColsIndex)
    quantColsIndex=setdiff((1:nc),qualColsIndex);
    qualCols=dataTable(:,qualColsIndex);
    quantCols=dataTable(:,quantColsIndex);

    [iM]=X2IndicatorBM(qualCols);
    oneHot=[quantCols,iM];
    N = numel(quantColsIndex);
else %oops
    fprintf('Warning: no qualCols fed into makeOneHotEmbedBMPNP \n');
    oneHot=dataTable;
    N = nc; %number of quant cols
    %centerReduced=oneHot;
    %var1=oneHot;
    %varEqual=oneHot;
end


if isfield(Params,'rescale')
    if strcmp(Params.rescale,'FAMD')
        oneHot = FAMDrescale(oneHot,N);
    elseif strcmp(Params.rescale,'wFAMD')
        oneHot = FAMDrescale(oneHot,N);
        %then fix kurtosis
        kurtMax = 10; %oops should be a parameter
          MV=kurtosis(oneHot(:,1:N))/3; %Maybe change in terms of weighting
          MV=min(MV(1,1:N),kurtMax);
          MV=max(MV(1,1:N),1);
          oneHot(:,1:N) = oneHot(:,1:N).*MV;
    end
end
end

function [indicatorMatrix]=X2IndicatorBM(X,varargin)
    [nr,nc]=size(X);
    for c=1:nc
        YK{c}=X(:,c)==1:max(X(:,c)); %ahhah good luck figuring that out
    end
    indicatorMatrix=cat(2,YK{:});    
end

function [oneHot] = FAMDrescale(oneHot,N)
    %Performs FAMD rescaling along the lines of Pages
    %oneHot- table of mixed data - qual variables encoded as a contigency table
    %i.e. one-hot i.e. indicator
    %N- first N columns quant, rest qual
[I,nc]=size(oneHot);
%quant Variables: center ( mean 0) and reduce (variance 1)
    quantCol=oneHot(:,1:N);
    quantCol=(quantCol-sum(quantCol)/I)./std(quantCol); %centers and reduces  

%qual Variables: xik <- yik/pk-1
    qualCol=oneHot(:,N+1:end);
    NQual=sum(qualCol(1,:)); %Since indicator gives number of vars
    [I,K]=size(qualCol);
    pK=sum(qualCol)/I;
    qualCol=qualCol.*(1./pK)-ones(I,K); %xik <- yik/pk-1
    
%Recombine:
    oneHot=[quantCol,qualCol];  
end
