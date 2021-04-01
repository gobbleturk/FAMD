function[ROC,ROCCurve]=computeROC4(scoreVec,trueOutliers)
    % I belive this handles ties correctly
    scoreVec=scoreVec(:);
    trueOutliers=trueOutliers(:)';
    nOutlier=numel(trueOutliers);
    nDat=numel(scoreVec); %it better be I guess    
    nInlier=nDat-nOutlier;
    
    trueOutlierVec=zeros(nDat,1);
    trueOutlierVec(trueOutliers)=1;
    
    datSet=1:nDat;
    [~,sortScoreIdx]=sort(scoreVec);
    sortScoreIdx=flipud(sortScoreIdx);
    scoreVec = scoreVec(sortScoreIdx);
    outlierSort = trueOutlierVec(sortScoreIdx);
    
    idx=1;
    curScore=scoreVec(1);
    nCurOutlier=0;
    TruePositiveVec=zeros(nDat+1,0);
    FalsePositiveVec=zeros(nDat+1,0);
    curPts=1;
    while idx <= nDat
        while idx <= nDat && scoreVec(idx) == curScore
            nCurOutlier = nCurOutlier + outlierSort(idx);
            idx = idx + 1;
        end
        curPts = curPts + 1;
        TruePositiveVec(curPts,1) = nCurOutlier/nOutlier;
        FalsePositiveVec(curPts,1) = ((idx-1) - nCurOutlier)/nInlier;
        
        if idx <= nDat
            curScore = scoreVec(idx);

            nCurOutlier = nCurOutlier + outlierSort(idx);
            idx = idx + 1;
        end
       
    end
    
    if FalsePositiveVec(curPts) < 1 || TruePositiveVec(curPts) < 1
        curPts = curPts + 1;
        TruePositiveVec(curPts,1)=1;
        FalsePositiveVec(curPts,1)=1;
    end
    
    
    FalsePositiveVec = FalsePositiveVec(1:curPts,1);
    TruePositiveVec = TruePositiveVec(1:curPts,1);
    ROCCurve=[FalsePositiveVec,TruePositiveVec];
    ROC=trapz(FalsePositiveVec,TruePositiveVec);
    
end

