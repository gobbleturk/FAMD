function [embedStruct,algoNamesStruct] = Cell2Embed(CellResults)
%embedStruct : has embeddings as fields, each embedding has
% algo as fields which contain the cell results.
embedStruct = struct();
algoNamesStruct = struct();
for i = 1:numel(CellResults)
    curEmbed = CellResults{i}.EmbedName;
    curAlgo = CellResults{i}.AlgoName;
    if ~isfield(algoNamesStruct,curAlgo)
        algoNamesStruct.(curAlgo) = true;
    end
    if ~isfield(embedStruct,curEmbed)
        curEmbedStruct = struct();
        embedStruct.(curEmbed) = curEmbedStruct;
        
    end
    embedStruct.(curEmbed).(curAlgo) = CellResults{i};
    
end

