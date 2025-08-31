clear; clc; close all;

strategies = {'Drilling','Reaming','Boring'};

% Columns: [Accessibility, SurfaceFinish, Time, Cost]
D = [0.8  0.9  0.7  0.6;   % Drilling
     0.9  0.95 0.8  0.7;   % Reaming
     0.7  0.85 0.6  0.5];  % Boring

% Criterion types: 1=benefit, 0=cost
ctype = [1 1 0 0];

% -------- Entropy weights ----------
Xb = zeros(size(D));
for j = 1:numel(ctype)
    col = D(:,j);
    if ctype(j)==1
        Xb(:,j) = (col - min(col)) / max(eps, (max(col)-min(col)));
    else
        Xb(:,j) = (max(col) - col) / max(eps, (max(col)-min(col)));
    end
end
p = Xb ./ sum(Xb,1);
p(p<=0) = eps;
E = -sum(p .* log(p), 1) / log(size(D,1));
w_entropy = (1 - E) ./ sum(1 - E);

% Fuzzy AHP weights
w_fahp = [0.25 0.35 0.25 0.15];

% Hybrid weights
w = 0.5*w_entropy + 0.5*w_fahp;
w = w / sum(w);

% VIKOR
fstar  = zeros(1,size(D,2));  fminus = zeros(1,size(D,2));
for j=1:numel(ctype)
    if ctype(j)==1
        fstar(j) = max(D(:,j));  fminus(j) = min(D(:,j));
    else
        fstar(j) = min(D(:,j));  fminus(j) = max(D(:,j));
    end
end
v = 0.5; % compromise parameter

S = zeros(3,1); R = zeros(3,1);
for i=1:3
    term = zeros(1,4);
    for j=1:4
        if ctype(j)==1
            term(j) = w(j) * (fstar(j) - D(i,j)) / (fstar(j) - fminus(j) + eps);
        else
            term(j) = w(j) * (D(i,j) - fstar(j)) / (fminus(j) - fstar(j) + eps);
        end
    end
    S(i) = sum(term); R(i) = max(term);
end

Sstar=min(S); Sminus=max(S); Rstar=min(R); Rminus=max(R);
Q = 0.5*(S - Sstar)./(Sminus - Sstar + eps) + ...
    0.5*(R - Rstar)./(Rminus - Rstar + eps);

% Results
T = table(strategies(:), S, R, Q, ...
    'VariableNames', {'Strategy','S','R','Q'});
T = sortrows(T, 'Q', 'ascend');

disp('--- Entropy / FAHP / Hybrid weights ---');
disp(table({'Access';'SurfFinish';'Time';'Cost'}, ...
    w_entropy(:), w_fahp(:), w(:), ...
    'VariableNames', {'Criterion','w_Entropy','w_FAHP','w_Hybrid'}));

disp(' ');
disp('--- VIKOR ranking (lower Q is better) ---');
disp(T);

f = figure('Color','w'); bar(T.Q, 'FaceColor',[0.2 0.6 1], 'EdgeColor','k');
grid on; set(gca,'XTickLabel',T.Strategy,'XColor','k','YColor','k','FontName','Times New Roman');
ylabel('Q (VIKOR)'); title('VIKOR Ranking (Lower is Better)');
exportgraphics(f,'VIKOR_demo.png','Resolution',300);

