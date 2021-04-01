function isDense=checkDense(dataMatrix,varargin)

isDense=true;
[nr,nc]=size(dataMatrix);
tol=nr*1e-15;
if istable(dataMatrix)
    if isnumeric(dataMatrix)
        dataMatrix=table2array(dataMatrix);
    else
        isDense=false;
    end
end
    
if isDense %may still not be dense
    if isempty(varargin)
        [discreteCols]=learnDiscreteCols(dataMatrix);
    else
        discreteCols=varargin{1};
    end
    
    cIdx=1;
    while isDense && cIdx<=numel(discreteCols)
        col=dataMatrix(:,discreteCols(cIdx));
        minVal=min(col);
        maxVal=max(col);
        numVal=numel(unique(col));
        if minVal==1 && numVal==(maxVal)
            if norm(round(col)-col)>tol
                isDense=false;
            end
        elseif minVal==0 && numVal==maxVal+1
            %indedxes range from 0 to maxcat-1
            %should do something more efficient than full recoding...
            isDense=false;
        else
            isDense=false;
        end
        cIdx=cIdx+1;
    end
end