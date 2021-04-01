function[CellResults]=computeAllROC2(CellResults,trueOutliers)
     for i=1:numel(CellResults)
         curScores=CellResults{i}.OriginalScore;
         [curROC,curROCCurve]=computeROC4(curScores,trueOutliers);
         curCellCopy=CellResults{i};
         curCellCopy.ROC=curROC;
         curCellCopy.ROCCurve=curROCCurve;
         CellResults{i}=curCellCopy;
     end
end