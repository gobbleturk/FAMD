function [e bits els usages] = myentropy(data)

e=0;
els = {};

[urows w q] = unique(data, 'rows');
% find counts
uq = unique(q); 
usages = histc(q, uq); % counts

p = usages ./ sum(usages);

bits = -log2(p);
e = sum(p.*bits); 


for i=1:size(urows,1)
   els{i} = urows(i,:); 
   
   % ind = ismember(data(:,1), urows(i,1)); 
   % for j=2:size(data,2)
        % ind = ind & ismember(data(:,j), urows(i,j)); 
   % end
   % pi = sum(ind) / length(ind);
   % usages = [usages sum(ind)];
   % bits =[bits -log2(pi)];
   % e = e + pi * bits(i);
end



end

