clc; clear; close all;

% 定义已知参数
lr = 1.2; % 后轮到车重心的距离，单位：m
lf = 1.2; % 前轮到车重心的距离，单位：m
V = 5 * 1000 / 3600; % 速度，单位：m/s
w = 1.84; % 轮距，单位：m
safe_distance = 0.1; % 安全距离，单位：m

% 优化参数
nvars = 2; % 变量个数：前向距离和转弯角度
lb = [0, 0]; % 下界
ub = [5, pi/4]; % 上界

% 使用NSGA-II进行多目标优化
% options = optimoptions('gamultiobj', 'PopulationSize', 100, 'MaxGenerations', 200);
% [x, fval] = gamultiobj(@(x) multi_objective_function(x, w, safe_distance, lr, lf, V), nvars, [], [], [], [], lb, ub, options);

% % 提取最大角度和最小角度及其对应的前行距离
% [max_angle, max_idx] = max(x(:,2));
% [min_angle, min_idx] = min(x(:,2));
% max_distance = x(max_idx, 1);
% min_distance = x(min_idx, 1);

num_runs = 10;
solutions1 = zeros(num_runs, 2);
solutions2 = zeros(num_runs, 2);
for n = 1:num_runs
    options = optimoptions('gamultiobj', 'PopulationSize', 100, 'MaxGenerations', 200);
    [x, fval] = gamultiobj(@(x) multi_objective_function(x, w, safe_distance, lr, lf, V), nvars, [], [], [], [], lb, ub, options);
    [max_angle, max_idx] = max(x(:,2));
    [min_angle, min_idx] = min(x(:,2));
    max_distance = x(max_idx, 1);
    min_distance = x(min_idx, 1);
    solutions1(n, :) = [max_distance,max_angle];
    solutions2(n, :) = [min_distance,min_angle];
end

mean_solution1 = mean(solutions1);
std_solution1 = std(solutions1);
mean_solution2 = mean(solutions2);
std_solution2 = std(solutions2);

disp(['平均解: 直行距离 = ', num2str(mean_solution1(1)), ', 转弯角度 = ', num2str(rad2deg(mean_solution1(2))), ' 度']);
disp(['解的标准差: 直行距离 = ', num2str(std_solution1(1)), ', 转弯角度 = ', num2str(rad2deg(std_solution1(2))), ' 度']);
disp(['平均解: 直行距离 = ', num2str(mean_solution2(1)), ', 转弯角度 = ', num2str(rad2deg(mean_solution2(2))), ' 度']);
disp(['解的标准差: 直行距离 = ', num2str(std_solution2(1)), ', 转弯角度 = ', num2str(rad2deg(std_solution2(2))), ' 度']);


% 输出结果
% disp('最大角度及其对应的距离：');
% disp(['最大角度: ', num2str(rad2deg(max_angle)), ' 对应距离: ', num2str(max_distance)]);
% disp('最小角度及其对应的距离：');
% disp(['最小角度: ', num2str(rad2deg(min_angle)), ' 对应距离: ', num2str(min_distance)]);