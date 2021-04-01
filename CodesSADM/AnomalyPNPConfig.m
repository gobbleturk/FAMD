function[CellResults,Embeddings,EmbeddingsDetailed]=AnomalyPNPConfig(data,EmbedArray,varargin)
%Input: data, nr x nc mixed data matrix (dense coding, categorical are in [1,maxCat])
%varargin: Ground truth can be provided as a vector such as (1,5,15)
%Output: CellArrayResults is an array of result statitics such as anomaly
%scores Embeddings is a struct with fields of individuals embeddings; they are
%the full dimensional embeddings (Original,OneHot,FAMD, wFAMD, etc.)
%Embeddings Detailed are each variant (choosing dif number of dimensions,
%other bells and whistles, etc)

%Properties of CellResults:
% OriginalScore,
% EmbedName, 
% AlgoName,
% type ('A' for All, 'F' for First, 'FL' for first Last),  
% numDim, 
% rw ('' or 'r' or 'w or 'rw'), 
% mainEmbed ('FAMD','Original', 'OneHot'), 
% ROC (number), 
% ROCCurve, 
% shortName

addpath(genpath('Embeddings'))
addpath(genpath('Algorithms'))



runName = "";
if length(varargin)==1
    qualColsIndex=varargin{1};
    groundTruth=0;
elseif length(varargin)==2
    qualColsIndex=varargin{1};
    trueOutliers=varargin{2};
    groundTruth=1;
elseif length(varargin)==3
    qualColsIndex=varargin{1};
    trueOutliers=varargin{2};
    runName=varargin{3};
    groundTruth=1;
end

%%% Make Embeddings %%%
[EmbedArray,Embeddings,embedExtraArray]= makeEmbeddings(EmbedArray,data);

%% Make detailed embeddings (Number of dimensions, first+last, r, etc) %%

for i=1:numel(EmbedArray)
    curDetailed = EmbedArray(i).detailed;
    for j=1:numel(curDetailed)
        [embedName,embedStruct] = makeDetailedEmbed(EmbedArray(i),curDetailed(j),embedExtraArray{i},runName);
        EmbeddingsDetailed.(embedName) = embedStruct;
    end
end

%% Run Algos %%
CellResults= makeCellResults(EmbeddingsDetailed);

if groundTruth
    fprintf('Calculating AUC ROC... \n')
    CellResults=computeAllROC2(CellResults,trueOutliers);
    fprintf('AUC ROC Calculated! \n');
    %printROCTable(CellResults);
    [embedStruct,algoStruct] = Cell2Embed(CellResults);
    [ROCTable,embedNames,algoNames] = printROCTableFromEmbed(embedStruct,algoStruct);
end



end %mainFunc
function [embedName,detailedStruct] = makeDetailedEmbed(EmbedStruct,curDetailed,varargin)
    % for FAMD type embeddings, makes the detailed variant of it (choice of
    % First,Last, or First and Last dimensions, and the number of
    % dimensions)
    if ~isempty(varargin)
        extraEmbed = varargin{1}; 
        runName = varargin{2};
    end
        
    detailedStruct = EmbedStruct;    
    fullEmbed = EmbedStruct.Data;
    [nr,nc] = size(fullEmbed);
    if curDetailed.numDim == inf
        useAll = true;
    else
        useAll = false;
    end
    
    nameEmbed = EmbedStruct.Name;
    if strcmp(nameEmbed(1:2),'rw')
        detailedStruct.rw = 'rw';
    elseif strcmp(nameEmbed(1),'r')
        detailedStruct.rw = 'r';
    elseif strcmp(nameEmbed(1),'w')
        detailedStruct.rw = 'w';
    else
        detailedStruct.rw = '';
    end
    
    if curDetailed.numDim == -1 %% -1 special value for findElbow
        [numDim,idxLast] = findElbow(extraEmbed,curDetailed.type,runName,detailedStruct.rw);
        elbowFlag = true;
    else
        numDim = min(nc,curDetailed.numDim);
        elbowFlag = false;
    end
    
    type = curDetailed.type;
    detailedStruct.numDim = numDim;
    detailedStruct.type = type;
    if useAll
        allString = 'All_';
        detailedStruct.type = 'A'; %A for all
    else
        allString = '';
    end
    

    
    if strcmp(nameEmbed,'Original')
        detailedStruct.mainEmbed = 'Original';
    elseif strcmp(nameEmbed,'OneHot')
        detailedStruct.mainEmbed = 'OneHot';
    else
        detailedStruct.mainEmbed = 'FAMD';
    end
       
    embedName = string(EmbedStruct.Name) + string(type) + allString + string(numDim);
    embedName = char(embedName);
    if type == 'F'      
        embed = fullEmbed(:,1:numDim);
    elseif type == 'L'
        if elbowFlag
            embed = fullEmbed(:,idxLast:End);
        else
            embed = fullEmbed(:,end-(numDim-1):end);
        end
    elseif type == 'FL'
        if elbowFlag
            nFront = numDim; nLast = nc+1-idxLast;
            embed= [fullEmbed(:,1:nFront) fullEmbed(:,end-(nLast-1):end)];
        else
            nFront = ceil(numDim/2); nLast = floor(numDim/2);
            embed= [fullEmbed(:,1:nFront) fullEmbed(:,end-(nLast-1):end)];
        end
    else
        fprintf('Warning: type %s is not recognized, using full \n',type)
        embed = fullEmbed;
    end
    detailedStruct.Data = embed;
end


     
