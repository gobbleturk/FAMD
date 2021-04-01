function cost = totalCost(CT)


cost = 0;
%%%%%%%%%%%%%%%%%%%%%%
 % 1-encode the CTs %
%%%%%%%%%%%%%%%%%%%%%%
% 1.1-sum code lengths
for i=1:size(CT,1)
    codeLens = CT{i,4};
    ind = find(codeLens<inf);
    cost = cost+sum(codeLens(ind));
end
%fprintf('Code lengths total: %d\n',cost)

% 1.2-find labels encoding
allels = [];
for i=1:size(CT,1)
    els = CT{i,3};
    for j=1:length(els)
       elj = els{j};      
       for k=1:length(elj)
           allels = [allels; elj(k)];
       end
    end
end

%allels

% add label cost
[e, trash, trash, trash] = myentropy(allels);
labelcost = length(allels)*e;
%fprintf('Label encoding total: %d\n',labelcost)
cost = cost + labelcost;



%%%%%%%%%%%%%%%%%%%%%%
 % 2-encode the data %
%%%%%%%%%%%%%%%%%%%%%%
cost_temp = cost;

for i=1:size(CT,1)
   use = CT{i,5};
   codeLens = CT{i,4};
   ind = find(codeLens<inf);
   cost = cost+sum(codeLens(ind).*use(ind));
end

% for i=1:size(data,1)
% 
%     d = data(i,:);
%     
%     for j=1:size(CT,1)
%         dims = CT{j,1};
%         dd = d(dims);
%         
%         els = CT{j,3};
%         codeLens = CT{j,4};
%         for k=length(els):-1:1
%            elj = els{k};   
%            ind = ismember(dd, elj(1)); 
%            for t=2:length(elj)
%                ind = ind + ismember(dd, elj(t)); 
%            end
%            
%            if(sum(ind) == length(elj)) %includes this element
%               ix = find(ind>0);
%               dd(ix) = [];
%               cost = cost + codeLens(k);
%            end
%            if(length(dd) == 0) % this part of d is covered by this CT already
%                break;
%            end           
%         end
%     end
% 
% end

%fprintf('Data encoding total: %d\n',cost-cost_temp)

%fprintf('\nTotal cost: %d\n\n',cost)

end

