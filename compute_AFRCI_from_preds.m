clear; clc;

tbl = readtable('afr_preds.csv');  
classes = {'Through Hole','Blind Hole','Rectangular Pocket','Slot','Circular Boss'};

precision_fn = @(tp,fp) tp / max(1, (tp+fp));
recall_fn    = @(tp,fn) tp / max(1, (tp+fn));
f1_fn        = @(p,r) (2*p*r) / max(1e-12, (p+r));

N = height(tbl);
B = 2000;                             
rng(42);                               

results = table('Size',[numel(classes) 5], ...
    'VariableTypes', {'string','double','double','double','string'}, ...
    'VariableNames', {'Feature','Precision','Recall','F1','CI95_F1'});

for c = 1:numel(classes)
    cls = classes{c};
    y_true = strcmp(tbl.true_label, cls);
    y_pred = strcmp(tbl.pred_label, cls);

    TP = sum(y_true & y_pred);
    FP = sum(~y_true & y_pred);
    FN = sum(y_true & ~y_pred);

    P  = precision_fn(TP,FP);
    R  = recall_fn(TP,FN);
    F1 = f1_fn(P,R);

    F1_boot = zeros(B,1);
    idx = (1:N)';
    for b = 1:B
        res = idx(randi(N, N, 1));    
        ytr = strcmp(tbl.true_label(res), cls);
        ypr = strcmp(tbl.pred_label(res), cls);
        tp = sum(ytr & ypr);
        fp = sum(~ytr & ypr);
        fn = sum(ytr & ~ypr);
        p  = precision_fn(tp,fp);
        r  = recall_fn(tp,fn);
        F1_boot(b) = f1_fn(p,r);
    end
    ci = quantile(F1_boot,[0.025 0.975]);   % 95% CI
    halfwidth = (ci(2) - ci(1)) / 2;

    results.Feature(c)   = string(cls);
    results.Precision(c) = round(100*P,1);
    results.Recall(c)    = round(100*R,1);
    results.F1(c)        = round(100*F1,1);
    results.CI95_F1(c)   = sprintf('±%.1f', round(100*halfwidth,1));
end

disp('Table 8. AFR Model Accuracy for Feature Classification (with 95% CI)');
disp(results);

writetable(results, 'table8_afr_metrics_with_ci.csv');
