%% 符号解用来观察轨迹
clc; clear;
close all;

% 定义已知参数
lr = 1.2; % 后轮到车重心的距离，单位：m
lf = 1.2; % 前轮到车重心的距离，单位：m
L = lr + lf;
V = 20 * 1000 / 3600; % 速度，单位：m/s
delta_f = deg2rad(30); % 前轮偏角，单位：弧度
w = 1.84; % 汽车宽度，单位：m

% 定义时间范围
t_span = [0, 5]; % 模拟5秒

% 初始条件 [X0, Y0, psi0]
initial_conditions = [0, 0, pi/2];

% 使用ODE求解器求解轨迹
[t, Y] = ode45(@(t, Y) car_model(t, Y, V, delta_f, lr, lf), t_span, initial_conditions);

% 提取结果
X = Y(:, 1);
Y_pos = Y(:, 2);
psi = Y(:, 3);

% 计算四个轮子的轨迹
FL_x = zeros(size(X));
FL_y = zeros(size(Y_pos));
FR_x = zeros(size(X));
FR_y = zeros(size(Y_pos));
RL_x = zeros(size(X));
RL_y = zeros(size(Y_pos));
RR_x = zeros(size(X));
RR_y = zeros(size(Y_pos));

for i = 1:length(t)
    R_matrix = [cos(psi(i)), -sin(psi(i)); sin(psi(i)), cos(psi(i))];
    
    FL_offset = R_matrix * [lf; w/2];
    FR_offset = R_matrix * [lf; -w/2];
    RL_offset = R_matrix * [-lr; w/2];
    RR_offset = R_matrix * [-lr; -w/2];
    
    FL_x(i) = X(i) + FL_offset(1);
    FL_y(i) = Y_pos(i) + FL_offset(2);
    FR_x(i) = X(i) + FR_offset(1);
    FR_y(i) = Y_pos(i) + FR_offset(2);
    RL_x(i) = X(i) + RL_offset(1);
    RL_y(i) = Y_pos(i) + RL_offset(2);
    RR_x(i) = X(i) + RR_offset(1);
    RR_y(i) = Y_pos(i) + RR_offset(2);
end

% 绘制轨迹图
figure;
plot(X, Y_pos, 'DisplayName', '中心轨迹', 'LineWidth', 1);
hold on;
plot(FL_x, FL_y, 'DisplayName', '前左轮轨迹', 'LineWidth', 1);
plot(FR_x, FR_y, 'DisplayName', '前右轮轨迹', 'LineWidth', 1);
plot(RL_x, RL_y, 'DisplayName', '后左轮轨迹', 'LineWidth', 1);
plot(RR_x, RR_y, 'DisplayName', '后右轮轨迹', 'LineWidth', 1);

% 只为起点设置图例
plot(X(1), Y_pos(1), 'ko', 'MarkerFaceColor', 'k', 'DisplayName', '重心起点'); % 中心起点
plot(FL_x(1), FL_y(1),'ro', 'MarkerFaceColor', 'r', 'DisplayName', '前左轮起点'); % 前左轮起点
plot(FR_x(1), FR_y(1), 'go', 'MarkerFaceColor', 'g', 'DisplayName', '前右轮起点'); % 前右轮起点
plot(RL_x(1), RL_y(1), 'bo', 'MarkerFaceColor', 'b', 'DisplayName', '后左轮起点'); % 后左轮起点
plot(RR_x(1), RR_y(1), 'mo', 'MarkerFaceColor', 'm', 'DisplayName', '后右轮起点'); % 后右轮起点

% 不为后面的点设置图例
plot(X(10), Y_pos(10), 'k*', 'MarkerFaceColor', 'k', 'HandleVisibility', 'off');
plot(FL_x(10), FL_y(10), 'r*', 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
plot(FR_x(10), FR_y(10), 'g*', 'MarkerFaceColor', 'g', 'HandleVisibility', 'off');
plot(RL_x(10), RL_y(10), 'b*', 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');
plot(RR_x(10), RR_y(10), 'm*', 'MarkerFaceColor', 'm', 'HandleVisibility', 'off');

plot(X(20), Y_pos(20), 'k*', 'MarkerFaceColor', 'k', 'HandleVisibility', 'off');
plot(FL_x(20), FL_y(20), 'r*', 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
plot(FR_x(20), FR_y(20), 'g*', 'MarkerFaceColor', 'g', 'HandleVisibility', 'off');
plot(RL_x(20), RL_y(20), 'b*', 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');
plot(RR_x(20), RR_y(20), 'm*', 'MarkerFaceColor', 'm', 'HandleVisibility', 'off');

plot(X(30), Y_pos(30), 'k*', 'MarkerFaceColor', 'k', 'HandleVisibility', 'off');
plot(FL_x(30), FL_y(30), 'r*', 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
plot(FR_x(30), FR_y(30), 'g*', 'MarkerFaceColor', 'g', 'HandleVisibility', 'off');
plot(RL_x(30), RL_y(30), 'b*', 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');
plot(RR_x(30), RR_y(30), 'm*', 'MarkerFaceColor', 'm', 'HandleVisibility', 'off');

xlabel('X 位置 (m)');
ylabel('Y 位置 (m)');
title('汽车重心转弯轨迹');

% 设置X轴和Y轴的刻度间隔为1
set(gca, 'XTick', -10:1:2);
set(gca, 'YTick', -8:1:6);

grid on;

legend('show');

