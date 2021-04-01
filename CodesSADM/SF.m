function embedParamStruct = SF(type,numDim)
%Makes struct from inputs
%Inputs: type: String either 'F': front, 'L': last, 'FL': Front and last
%numDim: numDim to use, if FL uses half from front half from last
    embedParamStruct.type = type;
    embedParamStruct.numDim = numDim;
end