function [cost CT] =  buildModel(x, name, isavg)

%%%%%%%%%%%%%%%%%%%%%%
% This model follows a bottom-up approach and merges two feature-groups at a time.
% The merged CT has elements of possibly the previous CTs as well as
% elements with length equal to the cardinality of the merged feature groups., 
% yielding various-length sets. 
%%%%%%%%%%%%%%%%%%%%%

allt = tic;
%x = textread(filename);
% x is nxf data matrix

f = size(x,2);


% start with a separate (elementary) CT for each feature
CT= {}; % cell array for CT structures
for i=1:f
    [e codeLens elements usages] = myentropy(x(:,i));
    CT = add_CT(CT, [i], length(elements), elements, codeLens, usages);
end

% compute total cost with elementary tables
cost = totalCost(CT);

fprintf('Elementary total cost: %f \n', cost)


totalIGtime = 0;
% now, compute Information-Gain matrix of features for merging candidates

while(1) %--------------------------------------------------

    if(size(CT,1)<2)
		totaltime=toc(allt); 
		
		fprintf('\n\nTotal time is %f\n',totaltime);
		fprintf('Total IG time is %f\n',totalIGtime);
		fprintf('****************************************************\n')
		fprintf('Final total cost: %f \n', cost)
		fprintf('Number of CTs: %d \n', size(CT,1))
		fprintf('****************************************************\n')
	
        save(strcat('CT_',name,'.mat'),'CT')
        break;
    end

	if(size(CT,1) == f) % first round, build elementary IGs
		igt = tic;
		IG = zeros(size(CT,1),size(CT,1));
		if(isavg)		
			Fsize = zeros(size(CT,1),size(CT,1)); 
		end
		for i=1:size(CT,1)
			i
			[ei,trash,trash,trash] = myentropy(x(:,CT{i,1}));
			for j=i+1:size(CT,1)
				[ej,trash,trash,trash] = myentropy(x(:,CT{j,1}));
				[eij,trash,trash,trash] = myentropy(x(:,[CT{i,1} CT{j,1}]));
				IG(i,j)=ei+ej-eij;
				if(isavg), Fsize(i,j) = 2; end
			end
		end
		totalIGtime = totalIGtime + toc(igt);
		IG
	else % something is merged, update
		% find index of non-merged sets		
		igt = tic;
		allsets = (1:1:size(IG,1))';
		ind = ~ismember(allsets, ct1) & ~ismember(allsets, ct2);
		IG = IG(ind, ind);	
		IG = [IG zeros(sum(ind),1); zeros(1, sum(ind)+1)];
		
		if(isavg)
		Fsize = Fsize(ind, ind);	
		Fsize = [Fsize zeros(sum(ind),1); zeros(1, sum(ind)+1)];
		end
		% compute IG for new set and others
		[ej,trash,trash,trash] = myentropy(x(:,CT{end,1}));
		for i=1:size(CT,1)-1
			[ei,trash,trash,trash] = myentropy(x(:,CT{i,1}));			
			[eij,trash,trash,trash] = myentropy(x(:,[CT{i,1} CT{end,1}]));
			IG(i,end)=ei+ej-eij;
			if(isavg),	Fsize(i,end) = length(CT{i,1}) + length(CT{end,1}); end
		end
		totalIGtime = totalIGtime + toc(igt);
		%IG
		%if(isavg), Fsize, end
	end
	
	
    [ct1 ct2 ig] = find(IG);
	
	if(length(ct1) == 0)
		totaltime=toc(allt); 
		
		fprintf('\n\nTotal time is %f\n',totaltime);
		fprintf('Total IG time is %f\n',totalIGtime);
		fprintf('****************************************************\n')
		fprintf('Final total cost: %f \n', cost)
		fprintf('Number of CTs: %d \n', size(CT,1))
		fprintf('****************************************************\n')
	
        save(strcat('CT_',name,'.mat'),'CT')
        break;	
	end
	
	
    if(isavg)
	Fsizetmp = Fsize(unique(ct1),unique(ct2));
	[trash, trash, fsize] = find(Fsizetmp);
	ig = ig ./ fsize;
    end
	[sig ix] = sort(ig, 'descend');
    ctt1 = ct1(ix); ctt2 = ct2(ix);


    anymerged = false;
	% try to merge those groups with highest information gain in order
    for ct=1:length(ct1)

        % merge ct1(1) and ct2(1)
        ct1 = ctt1(ct);
        ct2 = ctt2(ct);
        fprintf('Trying to merge groups %d and %d\n', ct1, ct2)
        [CT{ct1,1} 0 CT{ct2,1}] % 0 separator for display
        
		% remove to-be-merged ones
        tempCT = CT;  
		tempCT(ct1,:) = [];
		tempCT(ct2-1,:) = [];
		% copy non-merging ones
        % for i=1:size(CT,1)
           % if( i ~= ct1 && i ~= ct2 ) % not a member
               % tempCT = add_CT(tempCT, CT{i,1},CT{i,2},CT{i,3},CT{i,4},CT{i,5});
           % end
        % end
        

       %%%%%%%%%%%%%%%%%%%%%%%%%%% build new CT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        newdims = [CT{ct1,1} CT{ct2,1}];
        newels = {};

		% add all unique rows to the new table
        fx = x(:,newdims);
        [urows w q] = unique(fx, 'rows');

        % find counts
        uq = unique(q); counts = histc(q, uq);
        [scounts ix] = sort(counts, 'descend');
        urows = urows(ix,:);

        %[urows scounts]
        %pause
        %fprintf('Length of unique rows %d\n',size(urows,1));
        
        for u=1:size(urows,1)
            newels{end+1} = urows(u,:); %--> add most frequent line            
        end
		
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if(1)
		% also add all the single items
		for d=1:length(newdims)
			singles = unique(x(:,newdims(d)));
			for s=1:length(singles)
				newels{end+1} = singles(s);
			end
		end
		end
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
        newnumrows = length(newels);
		newusages = zeros(newnumrows,1);
		newusages(1:size(urows,1)) = scounts;
        %newusages = newusages+1; %% correct for 0 usage
       
		% given usages, find codeLens
		newCodeLens = zeros(length(newusages),1)   + inf; 
		ind = find(newusages>0);    
		newCodeLens(ind) = -log2(newusages(ind)./sum(newusages));


		% now add the new CT to the rest
		tempCT = add_CT(tempCT, newdims, newnumrows, newels, newCodeLens, newusages);

		% now check the new total cost
		temp_cost = totalCost(tempCT);
				
		if(temp_cost < cost)
			fprintf('----------------------------------------------------\n')
			fprintf('Merging %d and %d reduced total cost to %f! \n', ct1, ct2, temp_cost)
			fprintf('----------------------------------------------------\n')
			CT = tempCT;
			cost = temp_cost;
			anymerged = true;
			break;	
		else
			fprintf('----------------------------------------------------\n')
			fprintf('Merging %d and %d did NOT reduce total cost! \n', ct1, ct2)
			fprintf('----------------------------------------------------\n')
		end
 
	end % trying to merge feature pairs



    % if no merge happened, break
    % otherwise continue to explore more merges
    if(~anymerged)
        
		totaltime=toc(allt); 
		fprintf('\n\nTotal time is %f\n',totaltime);
		fprintf('Total IG time is %f\n',totalIGtime);
		fprintf('****************************************************\n')
		fprintf('Final total cost: %f \n', cost)
		fprintf('Number of CTs: %d \n', size(CT,1))
		fprintf('****************************************************\n')
		
		save(strcat('CT_',name,'.mat'),'CT')
		break;
    end

end %- while ---------------------------------------------------------



function [dd covers] = isincover (dd, elj)
	%ind = ismember(dd, elj(1)); 
	%for t=2:length(elj)
	%	ind = ind + ismember(dd, elj(t)); 
	%end
	[trash, ai, trash] = intersect(dd, elj);
	
	
	%if(sum(ind) == length(elj)) %includes/covers this element
	if(length(ai) == length(elj)) %includes/covers this element
		%ix = find(ind>0);
		%dd(ix) = [];
		covers = true;
		dd(ai) = [];
	else
		covers = false;
	end
end



function trace = add_CT (trace0, dimensions, ...
                            numrows, ...
                            elementList, ...
                            codeLenList, ...
                            usages)
	ind=size(trace0,1)+1;
	trace = trace0;
	trace{ind,1} = dimensions;
	trace{ind,2} = numrows;
	trace{ind,3} = elementList;
	trace{ind,4} = codeLenList;
	trace{ind,5} = usages;
end


end

