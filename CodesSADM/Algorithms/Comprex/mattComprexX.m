function [scores] = comprexFromMixed(train,test,params)

postdata = mattBuildFeatureMatrix(train,params);
[~, CT] =  buildModelVar (postdata, params);
[scores] = computeCompressionScoresVar( postdata, CT );
