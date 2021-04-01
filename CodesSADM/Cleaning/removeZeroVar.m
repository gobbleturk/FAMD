function [varData,removedCols,varargout]=removeZeroVar(denseEncode,varargin)
% FAMD uses variance of each feature, if the feature has zero variance
% it contains no information and will also cause division by zero.
% Thus these features are removed in this function, while maintaining
% the correct qualCol vector in varargout

varD=var(denseEncode);
nonZeroVar=find(varD>0);
removedCols=find(varD==0);
varData=denseEncode(:,nonZeroVar);

if ~isempty(varargin)
    [~,nc]=size(varData);
    [~,ncO]=size(denseEncode);
    qualCols=varargin{1};
    if nc<ncO
        outQual=[];
        for i=1:nc
            if ismember(nonZeroVar(i),qualCols)
                outQual=[outQual i];
            end
        end
    else
        outQual=qualCols;
    end
    varargout{1}=outQual;
end
end
