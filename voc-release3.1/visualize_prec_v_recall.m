% Load the .mat files
just_person = load('voc-release3.1/voccache_pascal/person_pascal_model_pr_test_1_2007.mat');
with_head = load('voc-release3.1/voccache_pascal/person_comp_head_test_with_head.mat');
with_lowerbody = load('voc-release3.1/voccache_pascal/person_comp_head_test_with_lowerbody.mat');
with_upperbody = load('voc-release3.1/voccache_pascal/person_comp_head_test_with_upperbody.mat');
with_one = load('voc-release3.1/voccache_pascal/person_comp_head_test_with_one.mat');
with_two = load('voc-release3.1/voccache_pascal/person_comp_head_test_with_two.mat');
with_all = load('voc-release3.1/voccache_pascal/person_comp_head_test_with_all.mat');


% Create the line plot
figure;
plot(just_person.recall, just_person.prec, '-', 'DisplayName', sprintf('Just person (ap=%.2f)', just_person.ap), 'LineWidth', 3);
hold on;
plot(with_head.recall, with_head.prec, '--', 'DisplayName', sprintf('With head part (ap=%.2f)', with_head.ap), 'LineWidth', 1);
hold on
plot(with_lowerbody.recall, with_lowerbody.prec, '--', 'DisplayName', sprintf('With lowerbody part (ap=%.2f)', with_lowerbody.ap), 'LineWidth', 1);
hold on
plot(with_upperbody.recall, with_upperbody.prec, '--', 'DisplayName', sprintf('With upperbody (ap=%.2f)', with_upperbody.ap), 'LineWidth', 1);
hold on;
plot(with_one.recall, with_one.prec, '--', 'DisplayName', sprintf('With one part (ap=%.2f)', with_one.ap), 'LineWidth', 1);
hold on;
plot(with_two.recall, with_two.prec, '--', 'DisplayName', sprintf('With two parts (ap=%.2f)', with_two.ap), 'LineWidth', 1);
hold on;
plot(with_all.recall, with_all.prec, '--', 'DisplayName', sprintf('With all parts (ap=%.2f)', with_all.ap), 'LineWidth', 1);

xlim([0 1]);
ylim([0 1]);

% Add labels, title, and legend
xlabel('Recall');
ylabel('Precision');
title('Comparing precision acrossmodels', 'FontSize', 15);
legend('Location', 'best', 'FontSize', 14);
grid on;

% Show the plot
hold off;
