function[ROCTable,embedNames,algoNames]=printROCTableFromEmbed(embedStruct,algoStruct)
    embedNames = fieldnames(embedStruct);
    algoNames = fieldnames(algoStruct);
    ROCTable = cell(numel(embedNames),numel(algoNames));
    %print Header:
    headerText = 'ROC TABLE';
    fprintf('%15s',headerText)
    for i = 1:numel(algoNames)
        fprintf('%8s',algoNames{i})
    end
    fprintf('\n')
    
    naSTRING = 'N/A';
    for j = 1:numel(embedNames)
        curEmbed = embedStruct.(embedNames{j});
        fprintf('%15s', embedNames{j}) %Name of embedding
        for i = 1:numel(algoNames)
            curAlgo = algoNames{i};
            if isfield(curEmbed,curAlgo)
                fprintf('%8.4f',curEmbed.(curAlgo).ROC);
                ROCTable{j,i} = curEmbed.(curAlgo).ROC;
            else
                fprintf('%8s',naSTRING);
            end
        end
        fprintf('\n');
    end
end