%% 第三问，基于稀疏表示法
clc, clear, close all
% 定义曲线方程
f = @(x) x.^3 + x;

% 定义导数和二阶导数
f_prime = @(x) 3*x.^2 + 1;
f_double_prime = @(x) 6*x;

% 定义曲率计算公式
curvature = @(x) abs(f_double_prime(x)) ./ (1 + f_prime(x).^2).^(3/2);

% 生成采样点
x = linspace(0, 1, 100);
y = f(x);

% 计算曲率
kappa = curvature(x);

% 绘制原始曲线和曲率
figure;
subplot(2, 1, 1);
plot(x, y, 'b-', 'LineWidth', 1.5);
title('原始曲线 y = x^3 + x');
xlabel('x');
ylabel('y');
grid on;

subplot(2, 1, 2);
plot(x, kappa, 'r-', 'LineWidth', 1.5);
title('曲率');
xlabel('x');
ylabel('曲率 \kappa');
grid on;

%% 稀疏表示重构曲线

% 采样点数
num_samples = 100;

% 定义原始曲线弧长
s = zeros(1, num_samples);
for i = 2:num_samples
    ds = sqrt((x(i) - x(i-1))^2 + (y(i) - y(i-1))^2);
    s(i) = s(i-1) + ds;
end

% 定义曲率样本间隔
s_sample = linspace(0, s(end), num_samples);
curvature_sample = interp1(s, kappa, s_sample, 'spline');

% 初始化位置和方向
x_reconstructed = zeros(1, num_samples);
y_reconstructed = zeros(1, num_samples);
theta = zeros(1, num_samples);

% 初始方向
theta(1) = atan(f_prime(x(1)));

% 使用曲率重构曲线
for i = 2:num_samples
    ds = s_sample(i) - s_sample(i-1);
    theta(i) = theta(i-1) + curvature_sample(i) * ds;
    x_reconstructed(i) = x_reconstructed(i-1) + cos(theta(i)) * ds;
    y_reconstructed(i) = y_reconstructed(i-1) + sin(theta(i)) * ds;
end

% 绘制重构曲线
figure;
plot(x, y, 'b-', 'LineWidth', 1.5);
hold on;
plot(x_reconstructed, y_reconstructed, 'r--', 'LineWidth', 1.5);
title('原始曲线与重构曲线比较');
xlabel('x');
ylabel('y');
legend('原始曲线', '重构曲线');
grid on;

%% 计算误差
error = sqrt((x_reconstructed - x).^2 + (y_reconstructed - y).^2);

% 绘制误差
figure;
plot(x, error, 'k-', 'LineWidth', 1.5);
title('重构误差');
xlabel('x');
ylabel('误差');
grid on;

% 误差分析
disp('最大误差:');
disp(max(error));
disp('平均误差:');
disp(mean(error));
