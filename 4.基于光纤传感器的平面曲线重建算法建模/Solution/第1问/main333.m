clc, clear, close all

% 原始曲线方程
f = @(x) x.^3 + x;
df = @(x) 3*x.^2 + 1; % 导数
d2f = @(x) 6*x; % 二阶导数

num_points = 1000; % 用于计算弧长的点数
x = linspace(0, 1, num_points);
y = f(x);

s = zeros(1, num_points);
for i = 2:num_points
    ds = sqrt((x(i) - x(i-1))^2 + (y(i) - y(i-1))^2);
    s(i) = s(i-1) + ds;
end

% 等弧长采样
num_arc_samples = 6;
s_uniform = linspace(0, s(end), num_arc_samples);
x_uniform = interp1(s, x, s_uniform);
y_uniform = f(x_uniform);

% 计算每个采样点的曲率
curvature = abs(d2f(x_uniform)) ./ (1 + df(x_uniform).^2).^(3/2);

% 初始化位置和方向
x_reconstructed = zeros(1, num_arc_samples);
y_reconstructed = zeros(1, num_arc_samples);
theta = zeros(1, num_arc_samples);

% 初始方向
theta(1) = atan(df(x_uniform(1)));

% 使用曲率重构曲线
for i = 2:num_arc_samples
    ds = s_uniform(i) - s_uniform(i-1);
    theta(i) = theta(i-1) + curvature(i) * ds;
    x_reconstructed(i) = x_reconstructed(i-1) + cos(theta(i)) * ds;
    y_reconstructed(i) = y_reconstructed(i-1) + sin(theta(i)) * ds;
end

% 使用B样条曲线进行拟合
t = linspace(0, 1, num_arc_samples);
sp_x = spap2(1, 4, t, x_reconstructed);
sp_y = spap2(1, 4, t, y_reconstructed);

x_fit = fnval(sp_x, t);
y_fit = fnval(sp_y, t);

% 绘制原始曲线和重构曲线
figure(1);
plot(x, y, 'b-', 'LineWidth', 1.5);
hold on;
plot(x_reconstructed, y_reconstructed, 'r--', 'LineWidth', 1.5);
plot(x_fit, y_fit, 'g-.', 'LineWidth', 1.5);
title('原始曲线与重构曲线比较');
xlabel('x');
ylabel('y');
legend('原始曲线', '重构曲线', 'B样条拟合曲线');
grid on;

% 计算误差
error = sqrt((x_fit - x_uniform).^2 + (y_fit - y_uniform).^2);

figure(2)
plot(x, y, 'b-'); % 原始曲线
hold on;
for i = 1:num_arc_samples
    plot(x_uniform(i), y_uniform(i), 'ro'); % 等弧长划分的虚线
end
xlabel('x');
ylabel('y');
title('等弧长划分的虚线');
grid on;

% 绘制误差
figure(3);
plot(x_uniform, error, 'k-', 'LineWidth', 1.5);
title('重构误差');
xlabel('x');
ylabel('误差');
grid on;

% 误差分析
disp('最大误差:');
disp(max(error));
disp('平均误差:');
disp(mean(error));
