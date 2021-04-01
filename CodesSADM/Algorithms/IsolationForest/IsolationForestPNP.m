function [scores,Forest] = IsolationForestPNP(train, test,Params)
%
% F. T. Liu, K. M. Ting, and Z.-H. Zhou.
% Isolation forest.
% In Proceedings of ICDM, pages 413-422, 2008.
% 
% function IsolationForest: build isolation forest
%
% Input:
%     Data: n x d matrix; n: # of instance; d: dimension;
%     NumTree: # of isolation trees;
%     NumSub: # of sub-sample;
%     NumDim: # of sub-dimension;
%     rseed: random seed;
%
% Output:
%     Forest.Trees: a half space forest model;
%     Forest.NumTree: NumTree;
%     Forest.NumSub: NumSub;
%     Forest.NumDim: NumDim;
%     Forest.HeightLimit: height limitation;
%     Forest.c: a normalization term for possible usage;
%     Forest.ElapseTime: elapsed time;
%     Forest.rseed: rseed;
%

if nargin==2
    Params=IsoForestDefaultPNP(train);
end

NumTree=Params.NumTree;
NumSub=Params.NumSub;
NumDim=Params.NumDim;
HeightLimit=Params.HeightLimit;
rseed=5; %??
Params.rseed=rseed;

[NumInst, DimInst] = size(train);
NumDim=min(NumDim,DimInst);
Forest.Trees = cell(NumTree, 1);
Forest.NumTree = NumTree;
Forest.NumSub = NumSub;
Forest.NumDim = NumDim;
Forest.HeightLimit = 5*ceil(log2(NumSub));
Forest.c = 2 * (log(NumSub - 1) + 0.5772156649) - 2 * (NumSub - 1) / NumSub;
Forest.rseed = rseed;


% parameters for function IsolationTree
Params.HeightLimit = Forest.HeightLimit;
Params.NumDim = NumDim;


et = cputime;
for i = 1:NumTree
    
    if NumSub < NumInst % randomly selected sub-samples
        [temp, SubRand] = sort(rand(1, NumInst));
        IndexSub = SubRand(1:NumSub);
    else
        IndexSub = 1:NumInst;
    end
    if NumDim < DimInst % randomly selected sub-dimensions
        [temp, DimRand] = sort(rand(1, DimInst));
        IndexDim = DimRand(1:NumDim);
    else
        IndexDim = 1:DimInst;
    end
    
    Params.IndexDim = IndexDim;
    Forest.Trees{i} = IsolationTree(train, IndexSub, 0, Params); % build an isolation tree
   % Forest.Trees{i}=MakeParents(Forest.Trees{i});
    
end
Mass=IsolationEstimation(test,Forest);
scores=-mean(Mass,2);


Forest.ElapseTime = cputime - et;
