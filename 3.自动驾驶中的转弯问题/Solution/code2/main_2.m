%% 数值解版本
clc; clear;
close all;

% 定义已知参数
syms t;
lr = 1.2; % 后轮到车重心的距离，单位：m
lf = 1.2; % 前轮到车重心的距离，单位：m
L = lr + lf;
V = 20 * 1000 / 3600; % 速度，单位：m/s
delta_f = deg2rad(30); % 前轮偏角，单位：弧度
w = 1.84;

% 定义滑移角 beta
beta = atan(lr * tan(delta_f) / (lf + lr));

% 定义符号变量
syms X(t) Y_pos(t) psi(t);

% 定义微分方程
eqns = [
    diff(X, t) == V * cos(beta + psi);
    diff(Y_pos, t) == V * sin(beta + psi);
    diff(psi, t) == V * cos(beta) * tan(delta_f) / (lf + lr);
];

% 初始条件
conds = [X(0) == 0, Y_pos(0) == 0, psi(0) == pi/2];

% 求解微分方程
sol = dsolve(eqns, conds);

% 将解转换为函数句柄
X_sol = matlabFunction(sol.X);
Y_sol = matlabFunction(sol.Y_pos);
psi_sol = matlabFunction(sol.psi);

% 定义时间范围
time_points = 0:0.1:10; % 每隔0.1秒

% 计算轨迹
X_vals = X_sol(time_points);
Y_vals = Y_sol(time_points);
psi_vals = psi_sol(time_points);

% 计算四个轮子的坐标
wheel_offsets = [
    lf, w/2;  % 前左轮 (FL)
    lf, -w/2; % 前右轮 (FR)
    -lr, w/2; % 后左轮 (RL)
    -lr, -w/2 % 后右轮 (RR)
];

FL_x = zeros(size(time_points));
FL_y = zeros(size(time_points));
FR_x = zeros(size(time_points));
FR_y = zeros(size(time_points));
RL_x = zeros(size(time_points));
RL_y = zeros(size(time_points));
RR_x = zeros(size(time_points));
RR_y = zeros(size(time_points));

% 计算四个轮子的坐标
for i = 1:length(time_points)
    % 旋转矩阵
    R_matrix = [cos(psi_vals(i)), -sin(psi_vals(i)); sin(psi_vals(i)), cos(psi_vals(i))];
    
    % 计算四个轮子的偏移量
    FL_offset = R_matrix * wheel_offsets(1, :)';
    FR_offset = R_matrix * wheel_offsets(2, :)';
    RL_offset = R_matrix * wheel_offsets(3, :)';
    RR_offset = R_matrix * wheel_offsets(4, :)';
    
    % 计算全局坐标
    FL_x(i) = X_vals(i) + FL_offset(1);
    FL_y(i) = Y_vals(i) + FL_offset(2);
    FR_x(i) = X_vals(i) + FR_offset(1);
    FR_y(i) = Y_vals(i) + FR_offset(2);
    RL_x(i) = X_vals(i) + RL_offset(1);
    RL_y(i) = Y_vals(i) + RL_offset(2);
    RR_x(i) = X_vals(i) + RR_offset(1);
    RR_y(i) = Y_vals(i) + RR_offset(2);
end

% % 准备要写入Excel的数据
% data = cell(length(time_points), 11);
% for i = 1:length(time_points)
%     data{i, 1} = time_points(i);
%     data{i, 2} = X_vals(i);
%     data{i, 3} = Y_vals(i);
%     data{i, 4} = FL_x(i);
%     data{i, 5} = FL_y(i);
%     data{i, 6} = FR_x(i);
%     data{i, 7} = FR_y(i);
%     data{i, 8} = RL_x(i);
%     data{i, 9} = RL_y(i);
%     data{i, 10} = RR_x(i);
%     data{i, 11} = RR_y(i);
% end
% 
% % 设置表头
% header = {'时间/s', '车辆中心 x/m', '车辆中心 y/m', '前内轮中心 x/m', '前内轮中心 y/m', '前外轮中心 x/m', '前外轮中心 y/m', '后内轮中心 x/m', '后内轮中心 y/m', '后外轮中心 x/m', '后外轮中心 y/m'};

% % 将数据写入Excel文件
% filename = 'result2.xlsx';
% xlswrite(filename, [header; data]);

% 绘制轨迹图
figure(1)
plot(X_vals, Y_vals, 'DisplayName', '原始轨迹', 'LineWidth', 2);
hold on;
plot(FL_x, FL_y, 'bo', 'DisplayName', '前左轮');
plot(FR_x, FR_y, 'go', 'DisplayName', '前右轮');
plot(RL_x, RL_y, 'mo', 'DisplayName', '后左轮');
plot(RR_x, RR_y, 'co', 'DisplayName', '后右轮');
xlabel('X 位置 (m)');
ylabel('Y 位置 (m)');
title('汽车转弯轨迹');
legend('show');
grid on;

