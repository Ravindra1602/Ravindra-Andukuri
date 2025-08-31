% minimal_FAHPEntropy_VIKOR.m

clear; clc; close all;

strategies = {'Drilling','Reaming','Boring'};

% Raw decision matrix
D = [ 8.0,  8.8, 1.20, 3.6;   % Drilling
      9.0,  9.5, 1.50, 4.2;   % Reaming
      7.2,  8.4, 1.90, 5.0];  % Boring

% Criterion types: 1=benefit, 0=cost
ctype = [1 1 0 0];

% Fuzzy AHP pairwise matrix (triangular fuzzy numbers, TFNs)
A = cell(4);
A{1,1}=[1 1 1];  A{1,2}=[2 3 4];  A{1,3}=[4 5 6];  A{1,4}=[5 6 7];
A{2,1}=inv_tfn(A{1,2}); A{2,2}=[1 1 1]; A{2,3}=[3 4 5]; A{2,4}=[4 5 6];
A{3,1}=inv_tfn(A{1,3}); A{3,2}=inv_tfn(A{2,3}); A{3,3}=[1 1 1]; A{3,4}=[2 3 4];
A{4,1}=inv_tfn(A{1,4}); A{4,2}=inv_tfn(A{2,4}); A{4,3}=inv_tfn(A{3,4}); A{4,4}=[1 1 1];

alpha = 0.5;  
v     = 0.5;  

% ENTROPY weights
Xb = zeros(size(D));
for j = 1:numel(ctype)
    col = D(:,j);
    if ctype(j)==1
        Xb(:,j) = (col - min(col)) / max(eps, (max(col)-min(col)));
    else
        Xb(:,j) = (max(col) - col) / max(eps, (max(col)-min(col)));
    end
end
p = Xb ./ sum(Xb,1); p(p<=0)=eps;
E = -sum(p .* log(p), 1) / log(size(D,1));
w_entropy = (1 - E) ./ sum(1 - E);

%FAHP weights
w_fahp = fahp_weights_geomean(A);

% Hybrid weights
w = alpha*w_fahp + (1-alpha)*w_entropy;
w = w / sum(w);

% VIKOR on raw D with cost/benefit handling
fstar  = zeros(1,size(D,2));  fminus = zeros(1,size(D,2));
for j=1:numel(ctype)
    if ctype(j)==1
        fstar(j) = max(D(:,j));  fminus(j) = min(D(:,j));
    else
        fstar(j) = min(D(:,j));  fminus(j) = max(D(:,j));
    end
end

S = zeros(size(D,1),1); R = zeros(size(D,1),1);
for i = 1:size(D,1)
    term = zeros(1,size(D,2));
    for j = 1:size(D,2)
        if ctype(j)==1
            term(j) = w(j) * (fstar(j) - D(i,j)) / (fstar(j) - fminus(j) + eps);
        else
            term(j) = w(j) * (D(i,j) - fstar(j)) / (fminus(j) - fstar(j) + eps);
        end
    end
    S(i) = sum(term);
    R(i) = max(term);
end

Sstar=min(S); Sminus=max(S); Rstar=min(R); Rminus=max(R);
Q = v*(S - Sstar)./(Sminus - Sstar + eps) + ...
    (1-v)*(R - Rstar)./(Rminus - Rstar + eps);

% Outputs
T = table(strategies(:), S, R, Q, 'VariableNames', {'Strategy','S','R','Q'});
T = sortrows(T, 'Q', 'ascend');

disp('--- Weights (FAHP / Entropy / Hybrid) ---');
disp(table({'Access';'SurfFinish';'Time';'Cost'}, w_fahp(:), w_entropy(:), w(:), ...
    'VariableNames', {'Criterion','w_FAHP','w_Entropy','w_Hybrid'}));
disp(' ');
disp('--- VIKOR ranking (lower Q is better) ---'); disp(T);


% functions
function w = fahp_weights_geomean(A)
N = size(A,1); G = zeros(N,3);
for i=1:N
    prod_tfn=[1 1 1];
    for j=1:N, prod_tfn = tfn_mult(prod_tfn, A{i,j}); end
    G(i,:) = tfn_pow(prod_tfn, 1/N);
end
sumG = [sum(G(:,1)) sum(G(:,2)) sum(G(:,3))];
Wf = zeros(N,3);
for i=1:N, Wf(i,:) = tfn_div(G(i,:), sumG); end
w_crisp = mean(Wf,2)'; 
w = w_crisp / sum(w_crisp);
end
function b = inv_tfn(a), b=[1/a(3) 1/a(2) 1/a(1)]; end
function c = tfn_mult(a,b), c=[a(1)*b(1) a(2)*b(2) a(3)*b(3)]; end
function c = tfn_div(a,b),  c=[a(1)/b(3) a(2)/b(2) a(3)/b(1)]; end
function c = tfn_pow(a,p),  c=[a(1)^p a(2)^p a(3)^p]; end
