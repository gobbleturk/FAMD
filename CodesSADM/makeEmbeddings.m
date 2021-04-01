function [EmbedArray,Embeddings,embedExtraArray]= makeEmbeddings(EmbedArray,data)
%Driver to perform multiple embeddings (OneHot, FAMD, WFAMD, etc)
%Inputs: EmbedArray is a struct array with fields Name(String),
% Func(@Pointer to embedding Func), Params (Struct of params) and
% Algo (itself a struct of Algos to be run with embedding)
%data is an nr x nc Densely Encoded ( categorical in [1..n] matrix).
%Outputs: EmbedArray updates the struct array with new field: Data
%         Embeddings is a struct with fields of names with EmbedArray.Name

addpath(genpath('Embeddings'))
embedExtraArray = cell(1,numel(EmbedArray));
for i=1:numel(EmbedArray)
    curEmbeddedName=EmbedArray(i).Name;
    fprintf('\n %d: %s\n',i,curEmbeddedName)
    curEmbeddingFunc=EmbedArray(i).Func;
    curDefaultParams=EmbedArray(i).Params;
    [EmbedArray(i).Data,embedExtraArray{i}]=curEmbeddingFunc(data,curDefaultParams);
    Embeddings.(curEmbeddedName)=EmbedArray(i).Data;
end

end

