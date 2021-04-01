function [embedArray] = fixQualColProperty(embedArray,qualCols)
% if columns have been deleted (because of zero variance)
% then the qualColsIndex parameter of many embedding/scoring algorithms
% is now wrong, this will fix these parameters

for i=1:numel(embedArray)
    if isfield(embedArray(i).Params,'qualColsIndex')
        embedArray(i).Params.qualColsIndex = qualCols;
    end
    algos = embedArray(i).Algo;
    for j=1:numel(algos)
        if isfield(algos(j).Params,'qualColsIndex')
            algos(j).Params.qualColsIndex = qualCols;
            embedArray(i).Algo(j).Params.qualColsIndex= qualCols;
        end
    end   
end


