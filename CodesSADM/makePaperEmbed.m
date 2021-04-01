function [EmbedArray] = makePaperEmbed(data,qualColsIndex)
% Creates a "task list" of embedding + scoring algorithm  pairs
% to run anomaly detection on
% Inputs: data is an nObs x nDim data table, used to set parameters
% of embedding and scoring algorithms
% qualColsIndex is a vector of indexes for the qualitative (categorical)
% columns, such as [1,3,5] to indicate that the first,third, and fifth
% columns of data are categorical.
% Outputs: EmbedArray is a struct. Each top level struct
% represents an embedding, with fields:
% Func: function handle for the embedding algorithm, this function should have
%      two inputs (data,params) and output an embedding
% Params: struct of params to use as second argument to the Func
% Name: string used for the name
% Algo: struct of Algo structs (discussed below)
% detailed: when using FAMD or wFAMD two additional specifications are
% needed:
% (First,Last,or First and Last) and Number of dimension
% this is created using the function SF(type,numDim), see SF
% an array of SF outputs is expected in the detailed field 
% Algo structs have similar fields:
% Func: function handle for the embedding algorithm, this function should have
%    two inputs (data,params) and output an nObs x 1 vector of anom scores
% Params: struct of params to use as second argument
% Name: string used for the name

%Algorithms
%SPAD
SPADQAlgo.Func=@SPADDictQPNP;
SPADQAlgo.Params=@defaultSPAD;
SPADQAlgo.Name='SPAD';

%ISO
ISOAlgo.Func=@IsolationForestPNP;
ISOAlgo.Params=@IsoForestDefaultPNP;
ISOAlgo.Name='ISO';
   
%COMPREX
comprexAlgo.Func = @mattComprexX;
comprexAlgo.Params = @defaultComprex;
comprexAlgo.Name = 'COMPREX';

AlgoStruct=struct([SPADQAlgo,ISOAlgo]);

%Embedding Creation
%Original
OriginalEmbed.Func=@IdentityFunc;
DefaultIdentityParamsS=struct();
OriginalEmbed.Params=DefaultIdentityParamsS;
OriginalEmbed.Name='Original';
OriginalEmbed.detailed=[SF('F',inf)];

%Spad on Original needs correct qualCols:
SPADOrigParams=defaultSPAD(data);
SPADOrigParams.qualColsIndex=qualColsIndex;
SPADQOrig=SPADQAlgo;
SPADQOrig.Params=SPADOrigParams;

comprexParams = defaultComprex(data);
comprexParams.qualColsIndex = qualColsIndex;
comprexOrig = comprexAlgo;
comprexOrig.Params = comprexParams;
OriginalEmbed.Algo=SPADQOrig;
%OriginalEmbed.Algo=([SPADQOrig,comprexOrig]);


%OneHot
OneHotEmbed.Func=@makeOneHotEmbedBMPNP;
OneHotParamsS=struct();
OneHotParamsS.qualColsIndex=qualColsIndex;
OneHotEmbed.Params=OneHotParamsS;
OneHotEmbed.Name='OneHot';
OneHotEmbed.Algo=ISOAlgo;
OneHotEmbed.detailed=[SF('F',inf)];

%All FAMD
%General FAMD Params: variants build off this
genFAMDParams=struct();
genFAMDParams.qualColsIndex=qualColsIndex;
genFAMDParams.NumDim=inf;
genFAMDParams.WeightChange=0;
genFAMDParams.Robust=false;

%Vanilla FAMD
FAMDEmbed.Func=@MattFAMDPNP;
FAMDEmbed.Params=genFAMDParams;
FAMDEmbed.Name='FAMD';
FAMDEmbed.Algo=AlgoStruct;
detailedFAMD = [SF('F',5)];
FAMDEmbed.detailed=detailedFAMD;

%WFAMD
wFAMDEmbed.Func=@MattFAMDPNP;
wFAMDEmbed.Params= genFAMDParams;
wFAMDEmbed.Params.WeightChange=1;
wFAMDEmbed.Name='wFAMD';
wFAMDEmbed.Algo=AlgoStruct;
detailedWFAMD = [SF('F',5),SF('FL',5)];
wFAMDEmbed.detailed=detailedWFAMD;



EmbedArray=struct([OriginalEmbed, OneHotEmbed, FAMDEmbed, wFAMDEmbed]);


end


