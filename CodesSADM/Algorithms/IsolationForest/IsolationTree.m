function Tree = IsolationTree(Data, CurtIndex, CurtHeight, Paras)
% 
% F. T. Liu, K. M. Ting, and Z.-H. Zhou.
% Isolation forest.
% In Proceedings of ICDM, pages 413-422, 2008.
% 
% function IsolationTree: build an isolation tree
% 
% Input:
%     Data: n x d matrix; n: # of instance; d: dimension (the whole data set);
%     CurtIndex: index of current data instance;
%     CurtHeight: current height;
%     Paras.IndexDim: sub-dimension index;
%     Paras.NumDim:  # of sub-dimension;
%     Paras.HeightLimit: maximun height limitation;
%     Paras.dimUniformSample (0 or 1, 1 for uniform, 0 for RRCF)
% Output:
%     Tree: an isolation tree model
%     Tree.NodeStatus: 1: inNode, 0: exNode;
%     Tree.SplitAttribute: splitting attribute;
%     Tree.SplitPoint: splitting point;
%     Tree.LeftChild: left child tree which is also a half space tree model;
%     Tree.RightChild: right child tree which is also a half space tree model;
%     Tree.Size: node size;
%     Tree.Height: node height;
% 

Tree.Height = CurtHeight;
NumInst = length(CurtIndex);

if isfield (Paras,'dimUniformSample')
    dimUniformSample=Paras.dimUniformSample;
else
    dimUniformSample=1;
end

if CurtHeight >= Paras.HeightLimit || NumInst <= 1
    Tree.NodeStatus = 0;
    Tree.SplitAttribute = [];
    Tree.SplitPoint = [];
    Tree.LeftChild = [];
    Tree.RightChild = [];
    Tree.Size = NumInst;
    return;
else
    Tree.NodeStatus = 1;
     if dimUniformSample
         %Select attribute (dimension) proportial to its size
        [temp, rindex] = max(rand(1, Paras.NumDim));
    else
        %Select according to RRCF, prop to dim width
        curtDataMatrix=Data(CurtIndex,Paras.IndexDim);
        minBox=min(curtDataMatrix);
        maxBox=max(curtDataMatrix);
        boxWidths=maxBox-minBox;
        cumSumWidths=cumsum(boxWidths);
        r=rand*cumSumWidths(end);
        rindex=find(cumSumWidths>r,1);
        if isempty(rindex)
            rindex=Paras.NumDim;
        end
    end

    Tree.SplitAttribute = Paras.IndexDim(rindex);
    CurtData = Data(CurtIndex, Tree.SplitAttribute);
    Tree.SplitPoint = min(CurtData) + (max(CurtData) - min(CurtData)) * rand(1);
    
    % instance index for left child and right children
    LeftIdx=CurtData<Tree.SplitPoint;
    LeftCurtIndex=CurtIndex(LeftIdx);
    RightCurtIndex=CurtIndex(~LeftIdx);
    %LeftCurtIndex = CurtIndex(CurtData < Tree.SplitPoint);
    %RightCurtIndex=CurtIndex(CurtData>=Tree.SplitPoint); 
    %RightCurtIndex = setdiff(CurtIndex, LeftCurtIndex); Is this hella
    %slow?
    
    % bulit right and left child trees
    Tree.LeftChild = IsolationTree(Data, LeftCurtIndex, CurtHeight + 1, Paras);
    Tree.RightChild = IsolationTree(Data, RightCurtIndex, CurtHeight + 1, Paras);
    
    iTree.size = [];
end
