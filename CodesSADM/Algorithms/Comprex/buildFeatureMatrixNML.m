function buildFeatureMatrixNML(filename, maxnumbins, epsilon, delta)


data = textread(filename);
size(data)

binned = [];
for i=1:size(data,2)
	d = data(:,i);
	x = nmlbin( d, maxnumbins, epsilon, delta); %std(d), std(d) );
	[min(x) max(x)]
	binned = [binned x];
end


postdata = featurepost(binned);
dlmwrite(strcat(filename,'_',num2str(maxnumbins),'nmlbins_eps.txt'), postdata,'delimiter',' ');



    function binnedd = nmlbin( d, maxnumbins, eps, delta )
        dlmwrite('temp.txt', d);
	cmd = strvcat(['./NML_histogram temp.txt ' num2str(maxnumbins) ' ' num2str(eps) ' ' num2str(delta)]);
        system(cmd);
        
        %read in the cut points
        cuts = textread('cuts.txt');
	%pause
        
        N = length(d);
        binnedd = zeros(N,1)-1;
	
        for c=1:length(cuts)-2
            ind = find(d>=cuts(c) & d<cuts(c+1));
            binnedd(ind) = c;
        end
        ind = find(d>=cuts(end-1) & d<=cuts(end));
        binnedd(ind) = length(cuts)-1;

    end

	function data = featurepost(data)
		for k=2:size(data,2)
   			data(:,k) = max(data(:,k-1))+data(:,k); 
		end	
	end




end
