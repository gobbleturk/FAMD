function scores = logbin( n, p )
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here

N = length(n);
scores = zeros(N,1)-1;

[s sind] = sort(n);

score = 1;
numcovered = 0;
while (N>0)
    upperind = ceil(N*p); 
    val = s(numcovered+upperind);
    
    ind = find(s<=val);
    T = ind(numcovered+1:end);
    scores(sind(T)) = score;
    score = score+1;
    
    N = N-length(T);
    numcovered = numcovered+length(T);
end



end

