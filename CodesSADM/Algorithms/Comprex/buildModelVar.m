function [cost, CT] =  buildModelVar (x, params)

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

isavg = params.isavg;

% start with a separate (elementary) CT for each feature
CT= {}; % cell array for CT structures
for i=1:f
    [e codeLens elements usages] = myentropy(x(:,i));
    CT = add_CT(CT, [i], length(elements), elements, codeLens, usages);
end

% compute total cost with elementary tables
cost = totalCost(CT);


totaltime=toc(allt); 


totalIGtime = 0;
% now, compute Information-Gain matrix of features for merging candidates

triedgroups = {};

while(1) %--------------------------------------------------

    if(size(CT,1)<2)
		totaltime=toc(allt); 
			
        %save(strcat('CT_',name,'.mat'),'CT')
        break;
    end

	if(size(CT,1) == f) % first round, build elementary IGs
		igt = tic;
		IG = zeros(size(CT,1),size(CT,1));
		if(isavg),		Fsize = zeros(size(CT,1),size(CT,1)); end
		for i=1:size(CT,1)
			[ei , trash, trash, trash] = myentropy(x(:,CT{i,1}));
			for j=i+1:size(CT,1)				
				[ej , trash, trash, trash] = myentropy(x(:,CT{j,1}));
				[eij, trash, trash, trash] = myentropy(x(:,[CT{i,1} CT{j,1}]));
				IG(i,j)=ei+ej-eij;
				if(isavg), Fsize(i,j) = 2; end
			end
		end
		totalIGtime = totalIGtime + toc(igt);
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
		[ej , trash, trash, trash] = myentropy(x(:,CT{end,1}));
		for i=1:size(CT,1)-1
			[ei , trash, trash, trash] = myentropy(x(:,CT{i,1}));			
			[eij, trash, trash, trash] = myentropy(x(:,[CT{i,1} CT{end,1}]));
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
        %save(strcat('CT_',name,'.mat'),'CT')
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
        newgroup = [CT{ct1,1} 0 CT{ct2,1}]; % 0 separator for display
        
        if(checkiftried(newgroup, triedgroups))
            ann = 1337;
            continue;
        else
            triedgroups{end+1} = newgroup; 
        end
                
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
        		
		% put all the elements from both tables together
		newels = {};
		elsct = CT{ct1,3};
		newusages = CT{ct1,5};
        for i=1:length(elsct)
           newels{end+1} =  elsct{i};
        end
        elsct = CT{ct2,3};
		newusages = [newusages; CT{ct2,5}];
        for i=1:length(elsct)
           newels{end+1} =  elsct{i};
        end

        % sort elements first by length (from shorter to longer), --newcoming ones will be longer
		% second by usage (from lower to higher) --scan for cover begins from end, will be faster if high freq. elements are encountered earlier.
        ellens = cellfun('length',newels)';
		[trash, ind] = sortrows([ellens newusages],[1 2]);
        newels = newels(ind);
        %ellens = ellens(ind);
		newusages = newusages(ind);
		
		%[ellens newusages]
        
		% try adding the most frequent rows of merged feature groups 1 by 1 in order
		fx = x(:,newdims);
        [urows w q] = unique(fx, 'rows');
        % find counts
        uq = unique(q); counts = histc(q, uq);
        [scounts ix] = sort(counts, 'descend');
        urows = urows(ix,:);
		
		numnoreduce = 0;
		temp_cost_prev = 0;
		U = size(urows,1);
		%least1 = 0;
		for u=1:U

			%if(least1==0 && scounts(u) < 280000)
			%	break;
			%end
			%least1 = 1;
            		newels{end+1} = urows(u,:); %--> add most frequent line   
			newusages = [newusages; scounts(u)];
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% update usages for those overlapping ones %
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			dd = newels{end};
			for k=(length(newels)-u):-1:1
				
				[dd covers] = isincover (dd, newels{k});
				% covers: true/false
				% dd: remaining uncovered part
				if(covers)
					newusages(k) = newusages(k) - newusages(end);
					assert(newusages(k)>-1)
				end
				if(length(dd) == 0)
					break;
				end
			end
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% find >1 length elements with usage 0 and remove them %
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			lens = cellfun('length',newels)';
			ind = find(lens > 1 & newusages==0);
			
			newels(ind) = [];
			newusages(ind) = [];
			lens(ind) = [];
			
			[trash, ind] = sortrows([lens newusages],[1 2]);
			newels = newels(ind);
			newusages = newusages(ind);
			%[cellfun('length',newels)' newusages]
			
			newnumrows = length(newels);
			
			% given usages, find codeLens
			newCodeLens = zeros(length(newusages),1)   + inf; 
			ind = find(newusages>0);    
			newCodeLens(ind) = -log2(newusages(ind)./sum(newusages));
			
			% now add the new CT to the rest
			tempCT = add_CT(tempCT, newdims, newnumrows, newels, newCodeLens, newusages);

			% now check the new total cost
			temp_cost = totalCost(tempCT);
			
			if(round(temp_cost) >= round(temp_cost_prev))
				numnoreduce = numnoreduce+1;
			else
				numnoreduce = max(0, numnoreduce-1);
			end
			
			if(temp_cost < cost)			
				CT = tempCT;
				cost = temp_cost;
				anymerged = true;
				% continue inserting for probable further reduced cost				
            else
				% continue inserting for probable future reduced cost								
			end
			
			% if it has been increasing for so many times consecutively
			if(numnoreduce ==5), break; end	

			% remove the CT from the end
			tempCT(end,:) = [];
			
			temp_cost_prev = temp_cost;
			
        	end % inserting freq. rows 1 by 1
		
        	if(anymerged)
			   p = 1337;
			break;
		end
 
	end % trying to merge feature pairs

    % if no merge happened, break
    % otherwise continue to explore more merges
    if(~anymerged)
        
		
		%save(strcat('CT_',name,'.mat'),'CT')
		break;
    end

end %- while ---------------------------------------------------------


function iscovered = checkiftried(newgroup, triedgroups)
    iscovered = false;
    for tr=1:length(triedgroups)
        if(length(newgroup) ~= length(triedgroups{tr}))
           continue; 
        end
        ai = intersect(newgroup, triedgroups{tr});
        if(length(ai) == length(newgroup))
            iscovered = true;
            break;
        end
    end
end


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

