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
k = interp1(os, k1, s, 'spline');

% 初始化变量
n = length(k); % 曲率数组的长度
x = zeros(1, n); % x 坐标数组
y = zeros(1, n); % y 坐标数组
theta = zeros(1, n); % 角度数组

% 初始点坐标和角度
x(1) = 0;
y(1) = 0;
theta(1) = deg2rad(45); % 初始角度

% 步长
ds = 0.01;

% 循环计算每一个点的坐标
for i = 2:n
    % 计算当前点的角度
    dtheta = k(i) * ds; % 曲率乘以步长得到角度变化
    theta(i) = theta(i-1) + dtheta; % 累加角度变化
    
    % 坐标变换矩阵
    T = [cos(theta(i)), -sin(theta(i)), x(i-1); 
         sin(theta(i)), cos(theta(i)), y(i-1);
         0, 0, 1];
     
    % 当前点相对前一点的坐标
    dx = ds;
    dy = 0;
    
    % 当前点的相对坐标向量
    P_rel = [dx; dy; 1];
    
    % 计算当前点的绝对坐标
    P_abs = T * P_rel;
    x(i) = P_abs(1);
    y(i) = P_abs(2);
end

% 绘制曲线
plot(x, y, 'g');
xlabel('X坐标');
ylabel('Y坐标');
title('曲线重建');
axis equal;
