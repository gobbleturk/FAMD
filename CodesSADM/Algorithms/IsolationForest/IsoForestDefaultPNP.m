function [IsoForestParams] = IsoForestDefaultPNP(data)

[nr,nc]=size(data);
IsoForestParams.NumTree=100;
IsoForestParams.NumSub=min(128,nr);
IsoForestParams.NumDim=min(nc,15);%FUCK
IsoForestParams.HeightLimit=10;
IsoForestParams.rseed=5; %heeheheh
IsoForestParams.dimUniformSample=1;
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


end

