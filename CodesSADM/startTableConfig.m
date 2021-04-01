function [CR,E,Edet,dataMat,qualCols]=startTableConfig(inputTable,embedArray,varargin)
%Cleans: Fill missing, makes categorical dense (in [1,numCat]),
%removeZeroVar, and puts all categorical variables at the end
%then runs AnomalyPNPConfig
%Inputs: inputTable: ugly data, missing values, can be as matrix or table
%or who knows what
%varargin: varargin{1} is indexes of qualCols, such as [3,5,8], if empty,
%we will try to automatically determine them, but there is no guarentee of determining integer
%values as categorical or not, set to -1 for this auto-learning
% varargin{2} is ground truth anom indexes, e.g. [2,5,6]
% varargin{3} is runName (string) for the current run which will be 
% used in the name of various saved outputs


anomIdx=[];
runName=-1;
if isempty(varargin) %This is not guaranteed to work, it is highly
    % recommended to specify the qualCols as the third argument 
    qualCols=learnColTypesTable(inputTable); 
elseif length(varargin)==1 %Assumes given qualCols, but no ground truth
    qualCols=varargin{1};
elseif length(varargin)==2
    if varargin{1}==-1 %Encoding for missing qualCols
        qualCols=learnColTypesTable(inputTable);
    else
        qualCols=varargin{1};
    end
    anomIdx=varargin{2};
elseif length(varargin)==3 % This is the expected main behavior 
    if varargin{1}==-1 %Encoding for missing qualCols
        qualCols=learnColTypesTable(inputTable);
    else
        qualCols=varargin{1};
    end
    anomIdx=varargin{2};
    runName=varargin{3};
end
    

tableFill=fillMissing2(inputTable,qualCols);
[denseEncode,~,qualCols]=makeDense(tableFill,qualCols);
[dataMat,~,qualCols]=removeZeroVar(denseEncode,qualCols);
embedArray = fixQualColProperty(embedArray,qualCols);

if runName==-1
    if ~isempty(anomIdx)
        [CR,E,Edet]=AnomalyPNPConfig(dataMat,embedArray,qualCols,anomIdx);
    else
        [CR,E,Edet]=AnomalyPNPConfig(dataMat,embedArray,qualCols);
    end
else
    if ~isempty(anomIdx)
        [CR,E,Edet]=AnomalyPNPConfig(dataMat,embedArray,qualCols,anomIdx,runName);
    else
        [CR,E,Edet]=AnomalyPNPConfig(dataMat,embedArray,qualCols,runName);
    end
end
   

end


