function buildFeatureMatrix(filename, numbins)


% load('egonetN.mat')
% load('egonetE.mat')
% load('egonetdirE.mat')
% load('egonetW.mat')
% load('egonetInW.mat')
% load('egonetOutW.mat')
% load('egonetInD.mat')
% load('egonetOutD.mat')

% load('egoInW.mat')
% load('egoOutW.mat')
% load('egoInD.mat')
% load('egoOutD.mat')

% load('egonetD.mat')
% load('egoBtwnCentral.mat')

% features = [egonetN egonetE egonetdirE egonetW egonetInW egonetOutW egonetInD egonetOutD egoInW egoOutW egoInD egoOutD egonetD egoBtwnCentral];
% save('features14.mat','features')

% load (filename)
data = textread(filename);
size(data)

binned = [];
for i=1:size(data,2)
	binned = [binned linbin( data(:,i), numbins )];
end

%binned(1:5,:)
postdata = featurepost(binned);




dlmwrite(strcat(filename,'_',num2str(numbins),'linbins.txt'), postdata,'delimiter',' ');


end