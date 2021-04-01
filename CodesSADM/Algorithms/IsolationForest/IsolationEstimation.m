function [Mass, ElapseTime, scores] = IsolationEstimation(TestData, Forest,varargin)
% 
% F. T. Liu, K. M. Ting, and Z.-H. Zhou.
% Isolation forest.
% In Proceedings of ICDM, pages 413-422, 2008.
% 
% function IsolationEstimation: estimate test instance mass on isolation forest
% 
% Input:
%     TestData: test data; nt x d matrix; nt: # of test instance; d: dimension;
%     Forest: isolation forest model;
% 
% Output:
%     Mass: nt x NumTree matrix; mass of test instances;
%     ElapseTime: elapsed time;
% 

NumInst = size(TestData, 1);
Mass = zeros(NumInst, Forest.NumTree);

if isempty(varargin)
    nTrain=NumInst;
else
    nTrain=varargin{1};
end

et = cputime;
for k = 1:Forest.NumTree
    Mass(:, k) = IsolationMass(TestData, 1:NumInst, Forest.Trees{k, 1}, zeros(NumInst, 1));
end
ElapseTime = cputime - et;

avgDepth=sum(Mass')'/Forest.NumTree;
scores=calcIsolationScore(avgDepth,nTrain);
end

function[scores]=calcIsolationScore(avgDepth,varargin)
    if isempty(varargin)
        n=length(avgDepth);
    else
        n=varargin{1};
    end
	H=log(n-1)+0.577; %
	c=2*H-(2*(n-1)/n);
	scores=exp(-log(2)*avgDepth/c); %2^-(depth/c)
end