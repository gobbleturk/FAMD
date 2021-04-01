function tableFill=fillMissing2(inputTable,qualCols)
    %Fills Missing Values - Continuous and Categorical treated Differently
    %Continuous - Median
    %Categorical - Missing set to new category
    [nr,nc]=size(inputTable);
    tableFill=inputTable; %Initialize to correct size
    VarNames=inputTable.Properties.VariableNames;
    for c=1:nc
        curCol=inputTable(:,c);
        if ismember(c,qualCols) %Discrete, Categorical
            fillColC=fillColCat(curCol);
            tableFill.(VarNames{c})=table2cell(fillColC);
        else %Numerical, Continuous
            fillColC=fillColCont(curCol);
            try
                tableFill.(VarNames{c})=table2cell(fillColC);
            catch
                tableFill.(VarNames{c}) = fillColC;
            end
            %cell2mat
        end
    end

end

function [outCol]=fillColCont(col)
    %Fills Single Continuous Colulmn - Continuous and Categorical treated Differently
    %Continuous - fill with median
    %col: table column- cell array where inside each cell can be a number,
    %string, or another cell (filled with number or string)
    %outCol - purely numeric column, missing values filled
    [nr,~]=size(col);   
    missStringVal={'','?'};
    nString=numel(missStringVal);
    strMissMat=zeros(nr,nString);
    useVal=col{1,1};
    if iscell(useVal)
        outCol=cell(nr,1); %final output
        for stringIdx=1:nString
            strMissMat(:,stringIdx)=strcmp(col{:,1},missStringVal{stringIdx});
        end
        try
            strMissVec=(sum(strMissMat,2)>0.5) | isnan(col);
        catch
            strMissVec=(sum(strMissMat,2)>0.5);
        end
        notMissVec=~strMissVec;
        notMissVal=cellfun(@str2num,col{notMissVec,1});

        fillVal=nanmedian(notMissVal);
        outCol(strMissVec,1)={fillVal};
        outCol(notMissVec,1)=num2cell(notMissVal);
    else
        outCol=col;
    end   
end

function [col]=fillColCat(col)
    %Fills Single Categorical Colulmn
    %Categorical - fill with new category
    %col: table column- cell array where inside each cell can be a number,
    %string, or another cell (filled with number or string)
    %outCol - cell array of strings, missing values filled
    [nr,~]=size(col);   
    missStringVal={'','?'};
    nString=numel(missStringVal);
    strMissMat=zeros(nr,nString);
    useVal=col{1,1};
    
    if iscell(useVal)
        for stringIdx=1:nString
            strMissMat(:,stringIdx)=strcmp(col{:,1},missStringVal{stringIdx});
        end
        try
            strMissVec=(sum(strMissMat,2)>0.5) | isnan(col);
        catch
            strMissVec=(sum(strMissMat,2)>0.5);
        end
        fillVal={'MattMissingVal'}; %hopefully this is a novel name
        col(strMissVec,1)=fillVal;
        
    elseif isnumeric(useVal)
            cellNan = isnan(col{:,1});
            fillVal= max(col{:,1}) + 1; % to be novel
            col{cellNan,1} = fillVal;
    end
        
end

