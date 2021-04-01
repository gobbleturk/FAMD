function[rowCoordP,Sb,colCoordP,rowCoordFull]=MattFAMDPNP(dataTable,Params)
% Performs FAMD, Factor Analysis of Mixed Data
% Inputs: dataTable: quant columns encoded succintly, i.e.
% J quant columns corresponding to J quant variables (not contigency)
% Params.qualColumns: set of column indexes corresponding to qualitative cols
% Params.NumDim: Number of dimension of embedding

%Re organizes table so that qual columns all appear at end
if nargin==1
    Params=FAMDDefaultPNP(dataTable);
end

qualColsIndex=Params.qualColsIndex;
NumDim=Params.NumDim;
isDense=checkDense(dataTable,qualColsIndex);
if ~isDense
    warning('FAMD has been fed non-dense input');
    dataTable=makeDense(dataTable,qualColsIndex);
end

[nr,nc]=size(dataTable);
qualCols=dataTable(:,qualColsIndex);
quantColsIndex=setdiff((1:nc),qualColsIndex);
quantCols=dataTable(:,quantColsIndex);
nQuant=length(quantColsIndex);
[iM]=X2IndicatorBM(qualCols);
%quant columns concatenated with indciator matrix of qual:
FAMDMat=[quantCols,iM];
[~,numDimOneHot]=size(FAMDMat);
NumDim=min(NumDim,numDimOneHot-numel(qualColsIndex));
NumDim = min(NumDim,nr);
[rowCoordP,colCoordP,Sb]=FAMDPages(FAMDMat,nQuant,Params);
rowCoordFull=rowCoordP(:,1:end-numel(qualColsIndex)); %chop last 
% singular vectors corresponding to zero eigenvalue
Sb = diag(Sb);
Sb = Sb(1:end-numel(qualColsIndex));
rowCoordP=rowCoordP(:,1:NumDim);

end
 
function [indicatorMatrix]=X2IndicatorBM(X)
    if ~isempty(X)
        [~,nc]=size(X);
        for c=1:nc
            YK{c}=X(:,c)==1:max(X(:,c));
        end
        indicatorMatrix=cat(2,YK{:});
    else
        indicatorMatrix=[];
    end
end

function [rowCoordP,colCoordP,Sb]=FAMDPages(CT,N,Params)
    %Performs FAMD along the lines of Pages
    %CT- table of mixed data - qual variables encoded as a contigency table
    %i.e. one-hot i.e. indicator
    %N- first N columns quant, rest qual
[I,~]=size(CT);
kurtMax = 10;

%quant Variables: center ( mean 0) and reduce (variance 1)
    quantCol=CT(:,1:N);
    quantCol=(quantCol-sum(quantCol)/I)./std(quantCol); %centers and reduces  

%qual Variables: xik <- yik/pk-1
    qualCol=CT(:,N+1:end);
    [I,K]=size(qualCol);
    pK=sum(qualCol)/I;
    qualCol=qualCol.*(1./pK)-ones(I,K); %xik <- yik/pk-1

%Recombine:
    Z=[quantCol,qualCol];    

%Construct individuals weights (typically 1/I)
    DV=(1/I)*ones(1,I);
    DV=DV(:); %store as column since rows of Z are individuals
    DHV=DV.^(1/2);
%Construct dimension weights (1 for quant, pk for qual columns)
    MV=[ones(1,N),pK]; %store as row since M stores columns weights
    if Params.WeightChange==1 %Use kurtosis weighting
        MV(1,1:N)=kurtosis(Z(:,1:N))/3; %Maybe change in terms of weighting
        MV(1,1:N)=min(MV(1,1:N),kurtMax);
        MV(1,1:N)=max(MV(1,1:N),1);
    end

  %Square root
  MHV=MV.^(1/2); %Have to be careful when it is multiplied to Z or V
                  %Z is stored row wise, Z.*MV
                  %V is stored columnwise, V.*MV(:) or MV.*(:) 
%SVD 
[Ub,Sb,Vb]=svd(DHV.*Z.*MHV,'econ');   
Ua=Ub./DHV;
Va=Vb./MHV(:); %Sa = Sb

rowCoordP=(Z.*MV)*Va; %XMU? %Principal Row Coord
colCoordP=(Z'.*DV')*Ua; %XDV? %Principal Col Coord %Is this right?
end



