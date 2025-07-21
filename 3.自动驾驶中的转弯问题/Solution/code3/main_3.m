clc; clear; close all;

% 定义已知参数
lr = 1.2; % 后轮到车重心的距离，单位：m
lf = 1.2; % 前轮到车重心的距离，单位：m
L = lr + lf;
V = 5 * 1000 / 3600; % 速度，单位：m/s
w = 1.84; % 轮距，单位：m
garage_length = 5;
safe_distance = 0.1; % 安全距离，单位：m

% 遗传算法参数设置
options = optimoptions('ga', 'PopulationSize', 50, 'MaxGenerations',100, 'FunctionTolerance', 1e-6);

% 目标函数：计算碰撞情况和距离
objective = @(x) collision_check(x, w,safe_distance, lr, lf, V);

% 约束条件：直行距离和转弯角度
lb = [0, 0]; % 下界 [直行距离, 转弯角度]
ub = [garage_length, pi/4]; % 上界 [直行距离, 转弯角度]

% 求解最小转弯角度问题
[sol_min, fval_min] = ga(objective, 2, [], [], [], [], lb, ub, [], options);

% 求解最大转弯角度问题
[sol_max, fval_max] = ga(objective, 2, [], [], [], [], lb, ub, [], options);

% 输出结果
disp('最小转弯角度和直行距离：');
disp(['直行距离：', num2str(sol_min(1)), ' m']);
disp(['转弯角度：', num2str(rad2deg(sol_min(2))),  ' °']);

disp('最大转弯角度和直行距离：');
disp(['直行距离：', num2str(sol_max(1)), ' m']);
disp(['转弯角度：', num2str(rad2deg(sol_max(2))), ' °']);


% % 多次运行GA
% num_runs = 50;
% solutions = zeros(num_runs, 2);
% fvals = zeros(num_runs, 1);
% 
% for i = 1:num_runs
%     [sol, fval] = ga(objective, 2, [], [], [], [], lb, ub, [], options);
%     solutions(i, :) = sol;
%     fvals(i) = fval;
% end
% % 检查解的稳定性
% mean_solution = mean(solutions);
% std_solution = std(solutions);
% mean_fval = mean(fvals);
% std_fval = std(fvals);
% 
% disp(['平均解: 直行距离 = ', num2str(mean_solution(1)), ', 转弯角度 = ', num2str(rad2deg(mean_solution(2))), ' 度']);
% disp(['解的标准差: 直行距离 = ', num2str(std_solution(1)), ', 转弯角度 = ', num2str(rad2deg(std_solution(2))), ' 度']);
% disp(['平均成本值: ', num2str(mean_fval)]);
% disp(['成本值的标准差: ', num2str(std_fval)]);
% disp(['最大角度：',num2str(max(rad2deg(mean_solution))),'°']);
% disp(['最小角度：',num2str(min(rad2deg(mean_solution))),'°'])

