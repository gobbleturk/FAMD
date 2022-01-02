function [CellResults] = makeCellResults(EmbeddingsDetailed)
%Driver to run algo-embedding combinations
%Inputs: EmbeddingsDetailed is a struct with fields of Embeddings
%Each Embeddings is itself a struct with important fields of Data
% and Algo (itself a struct of Algos to be run)
%Outputs: CellResults is a cellArray of results, containing Scores





c=1; %counter
EmbedNames=fields(EmbeddingsDetailed);

%imports
addpath(genpath('Algorithms'))
for i=1:numel(EmbedNames)
    curEmbeddedName=EmbedNames{i};
    curStruct= EmbeddingsDetailed.(curEmbeddedName);
    curData=curStruct.Data;
    [~,nc]=size(curData);
    fprintf('\n %d: %s\n',i,curEmbeddedName)
    curAlgoSet=curStruct.Algo;
    
    for j=1:numel(curAlgoSet)            
        curAlgoStruct=curAlgoSet(j);
        curAlgoFunc=curAlgoStruct.Func;
        curAlgoName=curAlgoStruct.Name;
        fprintf('%s: %d dimensional \n',curAlgoName,nc);
        curParamFunc=curAlgoStruct.Params;
        if ~isstruct(curAlgoStruct.Params)
            curParams=curParamFunc(curData);
        else
            curParams=curAlgoStruct.Params;
        end
        try
            curScores=real(curAlgoFunc(curData,curData,curParams)); %Some algos return complex -- look into
        catch
            fprintf('Algo Embed Combo Failed %s, %s \n',curAlgoName,curEmbeddedName)
            curScores=randn(size(curData,1),1);
        end

        
        curCell.OriginalScore=curScores;
        curCell.EmbedName=curEmbeddedName;
        curCell.AlgoName=curAlgoName;
        curCell.type = curStruct.type;
        curCell.numDim = curStruct.numDim;
        curCell.rw = curStruct.rw;
        curCell.mainEmbed = curStruct.mainEmbed;
        %shortName is added via separate function
        CellResults{c}=curCell;
        c=c+1;
    end%Algos
end%Embeddings

end

