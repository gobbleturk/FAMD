function comparePrecisionRecallAtk(filename, filenameKRIMP, dataname)

%suff = {'_logbins.mat_topk.txt', '_5bins.mat_topk.txt', '_10bins.mat_topk.txt'};
%name = {'Log-bins','5-bins','10-bins'};
suff = {''}; xname = {''};

for i=1:length(suff)
    maxvals = zeros(2,1);
    precs = {};
    recs = {};

    % our method goes here
    a = textread(strcat(filename,suff{i}));
    N = size(a,1);
    mnclass = min(a(:,2));
    mnsize = length(find(a(:,2) == mnclass));
    count = 0;
    precision = zeros(N,1);
    recall = zeros(N,1);
    for k=1:N
        if(a(k,2) == mnclass)
            count = count+1;
        end
        precision(k) = count/k;
  	recall(k) = count/mnsize;
        if(recall(k) == 1)
            maxvals(1) = k;
            break;
        end
    end    
    precs{1} = precision;
    recs{1} = recall;

   
    % krimp goes here
    a = textread(strcat(filenameKRIMP,suff{i}));
    N = size(a,1);
    mnclass = min(a(:,2));
    mnsize = length(find(a(:,2) == mnclass))
    count = 0;
    precision = zeros(N,1);
    recall = zeros(N,1);
    for k=1:N
        if(a(k,2) == mnclass)
            count = count+1;
        end
        precision(k) = count/k;
  	recall(k) = count/mnsize;
        if(recall(k) == 1)
            maxvals(2) = k;
            break;
        end
    end    
    precs{2} = precision;
    recs{2} = recall;



    

    avgprec = zeros(2,1);
    
    mrkr = {'r-','b--'};
    figure; hold all; 
    for j=1:2
       prec = precs{j};
       rec = recs{j};
       prec = prec(1:maxvals(j));
       rec = rec(1:maxvals(j));
       plot(rec, prec,mrkr{j},'LineWidth',3); 

       % compute average precision ~ area under uninterpolated precision-recall curve
       [u x y] = unique(rec,'first');
       precisionsatuniquerecall = prec(x);
       if(rec(1) == 0)
       		precisionsatuniquerecall = precisionsatuniquerecall(2:end);
       end
       assert(length(precisionsatuniquerecall)==mnsize)	
       avgprec(j) = sum(precisionsatuniquerecall)/length(precisionsatuniquerecall);
    end
    avgprec
    
    hleg1=legend(['CompreX:',' ',num2str(avgprec(1),4)], ['LOF:','           ',num2str(avgprec(2),4)]);
    set(hleg1,'Location','SouthEast', 'FontSize', 17.5)
    set(gca, 'FontSize', 17);
    xlabel('Detection rate/Recall', 'FontSize', 17);
    ylabel('Detection precision', 'FontSize', 17);
    ylim([0 1.01]);
    xlim([0 1.01]);
    title(strcat(dataname,'_{',xname{i},'}'), 'FontSize', 17)
    
end








