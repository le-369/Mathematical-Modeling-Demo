%% 第一问，使用算法2
clc, clear, close all
c = 4200;
lamda01 = 1529*ones(6,1);
lamda02 = 1540*ones(6,1);
lamda1 = [1529.808; 1529.807; 1529.813; 1529.812; 1529.814; 1529.809];
lamda2 = [1541.095; 1541.092; 1541.090; 1541.093; 1541.094; 1541.091];

% 计算曲率
k1 = c * (lamda1 - lamda01) ./ lamda01;
k2 = c * (lamda2 - lamda02) ./ lamda02;

os = 0:0.6:3;
s = 0:0.01:3;
figure(1);
k = interp1(os, k1, s, 'spline');

% plot(os, k1, 'o')
% hold on
% plot(s, k, '.-');

% 初始化位置和方向
x = zeros(length(s), 1);
y = zeros(length(s), 1);
fai = zeros(length(s), 1);  % 方向角

% 初始位置和方向
x(1) = 0;
y(1) = 0;
fai(1) = deg2rad(45);  % 初始方向角，45度

for i = 1:length(s)-1
    ds = s(i+1) - s(i);
    m = (k(i+1) - k(i)) / ds;
    n = k(i) - m * s(i);
    
    % 计算当前段的方向角
    fai(i+1) = fai(i) + k(i) * ds;
    
    % 计算当前段的位置增量
    theta = k(i) * ds;
    if k(i) ~= 0
        ds_arc = 2 * sin(theta / 2) / k(i);
    else
        ds_arc = ds;
    end
    dx = ds_arc * cos(fai(i) + theta / 2);
    dy = ds_arc * sin(fai(i) + theta / 2);
    
    % 更新位置
    x(i+1) = x(i) + dx;
    y(i+1) = y(i) + dy;
end

figure(2);
plot(x, y, 'o', 'LineWidth', 0.2);
xlabel('x')
ylabel('y')
title('光纤轨迹重建')
grid on