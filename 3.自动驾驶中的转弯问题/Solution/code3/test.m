% 参数设置
w = 1.84;
safe_distance = 0.1;
lr = 1.2;
lf = 1.2;
V = 5 * 1000 / 3600; % 速度，单位：m/s

% 优化范围
lb = [0, deg2rad(10)]; % 最小值
ub = [4, deg2rad(45)]; % 最大值

% 最大转弯角度优化
objective_max = @(x) collision_check_max(x, w, safe_distance, lr, lf, V);
options = optimoptions('ga', 'MaxGenerations', 100, 'PopulationSize', 50);
[sol_max, fval_max] = ga(objective_max, 2, [], [], [], [], lb, ub, [], options);

% 最小转弯角度优化
objective_min = @(x) collision_check_min(x, w, safe_distance, lr, lf, V);
[sol_min, fval_min] = ga(objective_min, 2, [], [], [], [], lb, ub, [], options);

% 结果
disp(['最大转弯角度: ', num2str(rad2deg(sol_max(2)))]);
disp(['前向距离 (最大): ', num2str(sol_max(1))]);

disp(['最小转弯角度: ', num2str(rad2deg(sol_min(2)))]);
disp(['前向距离 (最小): ', num2str(sol_min(1))]);