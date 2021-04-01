function [FAMDParams]=FAMDDefaultPNP(dataTable)
qualColsIndex=learnDiscreteCols(dataTable);
NumDim=20;
FAMDParams.qualColsIndex=qualColsIndex;
FAMDParams.NumDim=NumDim;
end