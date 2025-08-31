% Fuzzy Vikor Blind Hole
clear; clc;

D = [0.80 0.90 0.70 0.60;   % Drilling
     0.90 0.95 0.80 0.70;   % Reaming
     0.70 0.85 0.60 0.50];  % Boring
ctype = [1 1 0 0];          % 1=benefit, 0=cost
strategies = {'Drilling','Reaming','Boring'};

Xb = zeros(size(D));
for j = 1:numel(ctype)
    col = D(:,j);
    if ctype(j)==1
        Xb(:,j) = (col - min(col)) / max(eps,(max(col)-min(col)));
    else
        Xb(:,j) = (max(col) - col) / max(eps,(max(col)-min(col)));
    end
end
p = Xb ./ sum(Xb,1); p(p<=0)=eps;
E = -sum(p .* log(p), 1) / log(size(D,1));
w_entropy = (1 - E) ./ sum(1 - E);

w_fahp = [0.25 0.35 0.25 0.15];

w = 0.5*w_fahp + 0.5*w_entropy; w = w/sum(w);

fstar  = zeros(1,size(D,2));
fminus = zeros(1,size(D,2));
for j = 1:numel(ctype)
    if ctype(j)==1, fstar(j) = max(D(:,j));  fminus(j) = min(D(:,j));
    else,           fstar(j) = min(D(:,j));  fminus(j) = max(D(:,j));
    end
end

S = zeros(3,1); R = zeros(3,1);
for i = 1:3
    term = zeros(1,4);
    for j = 1:4
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
v = 0.5;
Q = v*(S - Sstar)./(Sminus - Sstar + eps) + ...
    (1-v)*(R - Rstar)./(Rminus - Rstar + eps);

T = table(strategies(:), round(Q,3), 'VariableNames', ...
          {'Machining_Alternative','Qi_Index'});

disp('Table (Blind Hole): Fuzzy VIKOR Q_i');
disp(T);

writetable(T, 'table_Fig16_blindhole_Q.csv');
