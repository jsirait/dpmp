% Load the .mat files
aData = load('/Users/junitasirait/dpmp/voc-release3.1/voccache/head_on_coco_head_test_1_2007.mat');
bData = load('/Users/junitasirait/dpmp/voc-release3.1/voccache/person_pascal_on_coco_head_test_2_2007.mat');

% Extract precision and recall fields
precisionA = aData.prec;
recallA = aData.recall;
precisionB = bData.prec;
recallB = bData.recall;

% Create the scatter plot
figure;
plot(recallA, precisionA, '-', 'DisplayName', 'head model (ap = 0.42)', 'LineWidth', 2);
hold on;
plot(recallB, precisionB, '-', 'DisplayName', 'person model (ap = 0.18)', 'LineWidth', 2);

xlim([0 1]);
ylim([0 1]);

% Add labels, title, and legend
xlabel('Recall');
ylabel('Precision');
title({'Precision vs Recall tested on COCO dataset', 'with upper body person images only'}, 'FontSize', 15);
legend('Location', 'best', 'FontSize', 14);
grid on;

% Show the plot
hold off;
