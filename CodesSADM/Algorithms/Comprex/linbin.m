function scores = linbin( n, c )
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here

N = length(n);
scores = zeros(N,1)-1;

mn = min(n);
mx = max(n);

size = (mx-mn)/c;

cuts = mn;
for i=1:c-1
	cuts = [cuts cuts(i)+size];
end

cuts = [cuts mx];

for i=1:c-1
	ind = find(n>=cuts(i) & n<cuts(i+1));
	scores(ind) = i;
end
ind = find(n>=cuts(end-1) & n<=cuts(end));
scores(ind) = c;
end

