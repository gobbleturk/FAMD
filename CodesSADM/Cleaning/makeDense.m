function [denseEncode,transformMap,newQual] = makeDense(dataTable,varargin)
% transforms categorical columns into standard [1,2,3,...,numCat] features
% i.e. feature "fruit" with categories "apple","orange","banana"
% could map "apple:1","orange:2","banana:3", so that these
% features can be treated numerically (eventaully to be binary encoded)

if ~istable(dataTable)
    dataTable=array2table(dataTable);
end

try
    nc=width(dataTable);
    nr=height(dataTable);
catch
  [nr,nc]=size(dataTable);
end

if isempty(varargin)
    qualColsIndex=learnDiscreteCols17(dataTable);
else 
    qualColsIndex=varargin{1};
end

quantColsIndex=setdiff((1:nc),qualColsIndex);
qualCols=dataTable(:,qualColsIndex);
quantCols=dataTable{:,quantColsIndex};

[denseCat,transformMap]=X2DenseMap2(qualCols);
if iscell(quantCols)
    quantCols=cell2mat(quantCols);
end
denseEncode=[quantCols,denseCat];
[~,nc]=size(quantCols);
[~,ncTotal]=size(denseEncode);
newQual=nc+1:1:ncTotal;
end

function [DenseMat]=X2Dense(X,varargin)
%else varargin=question names, then colNames will be based on question
%names
[nr,nc]=size(X);

%begin to create maps from col indexes to one-hots:
for c=1:nc
    colC=X(:,c);
    uniqueC{c}=unique(colC); 
    nVarC{c}=size(uniqueC{c});
end

DenseMat=zeros(nr,nc);
for r=1:nr
    DenseRow=zeros(1,nc);
    for c=1:nc
        curTable=uniqueC{c};
        for d=1:nVarC{c}
            try
                if strcmp(string(curTable{d,1}{1}),string(X{r,c}{1}))
                    DenseRow(1,c)=d;
                end
            catch
               if strcmp(string(curTable{d,1}),string(X{r,c}))
                   DenseRow(1,c)=d;
               end
            end
        end
    end
    DenseMat(r,:)=DenseRow;
end
end

function [DenseMat,transformMap]=X2DenseCell(X,varargin)
%questionaire format to indicator/one-hot format
%if varargin is empty colNames uses the column number
%else varargin=question names, then colNames will be based on question
%names
[nr,nc]=size(X);

%begin to create maps from col indexes to one-hots:
DenseMat=zeros(nr,nc);
for c=1:nc
    if c==nc
        y=32;
    end
    cellCol=table2cell(X(:,c));
    try
        uniqueCol=unique(cellCol); 
        isNumer=false;
    catch
        uniqueCol=unique(cell2mat(cellCol));
        isNumer=true;
    end
    [nVarC,~]=size(uniqueCol);
    fprintf('c=%3d, nVarC=%5d \n',c,nVarC)
    transformTo=(1:nVarC);
    if ~isNumer
        cellCol=removePeriodsFromStringCellArray(cellCol);
        uniqueCol=unique(cellCol);
        colTransform=subs(cellCol,uniqueCol,transformTo(:));
        transformMap{c}=uniqueCol;
        %colTransform=cell2mat(colTransform);
    else
        try
            colTransform=subs(cell2mat(cellCol)',uniqueCol,transformTo(:));
        catch
            try
                colTransform=subs(cell2mat(cellCol),uniqueCol,transformTo(:));
            catch
                colTransform=subs(cellCol,mat2cell(uniqueCol,ones(1,nVarC),1),transformTo(:));
            end
        end
    end
    maxCol=max(colTransform);
    if nc<20
        fprintf('c=%3d, max=%5d \n',c,maxCol);
    end
    DenseMat(:,c)=colTransform;
end

end

function [DenseMat,uniqueMat]=X2DenseMap(X,varargin)
%questionaire format to indicator/one-hot format
%if varargin is empty colNames uses the column number
%else varargin=question names, then colNames will be based on question
%names
[nr,nc]=size(X);


DenseMat=zeros(nr,nc);
uniqueMat=cell(1,1); %created 2/11/2020 
for c=1:nc
    cellCol=table2cell(X(:,c));
    try
        uniqueCol=unique(cellCol); 
        isNumer=false;
    catch
        uniqueCol=unique(cell2mat(cellCol));
        isNumer=true;
    end
    [nVarC,~]=size(uniqueCol);
    uniqueMat{c}=uniqueCol;
    fprintf('c=%3d, nVarC=%5d \n',c,nVarC)
    transformTo=(1:nVarC);
    transformMap=containers.Map(uniqueCol,transformTo);
    for r=1:nr
        DenseMat(r,c)=transformMap(cellCol{r,1});
    end
end

end

function [CellArray]=removePeriodsFromStringCellArray(CellArray)
    nCell=numel(CellArray);
    for i=1:nCell
        curStr=CellArray{i};
        curStr(curStr=='.')=[];
        CellArray{i}=curStr;
    end
end

function [DenseMat,uniqueMat]=X2DenseMap2(X,varargin)
% general categorical format {"male","female","male"}
% to index 1:nCat [1,2,1]
[nr,nc]=size(X);
DenseMat=zeros(nr,nc);
uniqueMat=cell(1,1);
for c=1:nc

    cellCol=table2cell(X(:,c));
    if isstr(cellCol{1,1})
        try
            uniqueCol=unique(cellCol); 
            isNumer=false;
        catch
            uniqueCol=unique(cell2mat(cellCol));
            isNumer=true;
        end
        [nVarC,~]=size(uniqueCol);
        uniqueMat{c}=uniqueCol;

        for val=1:nVarC
            findVal=find(strcmp(uniqueCol(val),cellCol));
            DenseMat(findVal,c)=val;
        end
    else
        try
            uniqueCol=unique(cellCol); 
            isNumer=false;
        catch
            uniqueCol=unique(cell2mat(cellCol));
            isNumer=true;
        end
        [nVarC,~]=size(uniqueCol);
        uniqueMat{c}=uniqueCol;

        for val=1:nVarC
            findVal=find(uniqueCol(val)==cell2mat(cellCol));
            DenseMat(findVal,c)=val;
        end
        
    end

end
end

