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
k1 = interp1(os, k2, s, 'spline');
k = k1;
%始末状态
x1(1)=0;
y1(1)=0;
x2(1)=0;
y2(1)=0;
x3(1)=0;
y3(1)=0;
x4(1) = 0;
y4(1) = 0;
omg(1)=deg2rad(45);
theta(1) = deg2rad(45);
d=0.01;ds = 0.01;
kk(1)=1;

for i=1:length(s)-1
    % 方法一，切角递推
    omg(i+1)=pi/4+trapz(s(1:i+1),k1(1:i+1));
    st=0.01*k1(i);
    ds(k1(i)~=0)=2*sin(st/2)/k1(i);
    ds(k1(i)==0)=0.01;
    dx=ds*cos(omg(i)+st/2);
    dy=ds*sin(omg(i)+st/2);
    x1(i+1)=x1(i)+dx;
    y1(i+1)=y1(i)+dy;
    
    % 方法二，通过梯形算法解曲率积分求得曲线位置
    fx(i+1)=cos(omg(i+1));
    fy(i+1)=sin(omg(i+1));
    x2(i+1)=trapz(s(1:i+1),fx(1:i+1));
    y2(i+1)=trapz(s(1:i+1),fy(1:i+1));
    
    % 方法三斜率递推算法
    kk(i+1)=tan(k1(i)*d+atan(kk(i)));
    x3(i+1)=x3(i)+d/sqrt(1+kk(i)^2);
    y3(i+1)=y3(i)+kk(i)*d/sqrt(1+kk(i)^2);

    % 方法四坐标变换算法
    % 计算当前点的角度
    dtheta = k(i+1) * ds; % 曲率乘以步长得到角度变化
    theta(i+1) = theta(i) + dtheta; % 累加角度变化
    % 坐标变换矩阵
    T = [cos(theta(i+1)), -sin(theta(i+1)), x4(i); 
         sin(theta(i+1)), cos(theta(i+1)), y4(i);
         0, 0, 1];
    % 当前点相对前一点的坐标
    dx = ds;
    dy = 0;
    % 当前点的相对坐标向量
    P_rel = [dx; dy; 1];
    % 计算当前点的绝对坐标
    P_abs = T * P_rel;
    x4(i+1) = P_abs(1);
    y4(i+1) = P_abs(2);
end

% 绘制第一个图像：三个曲线展示在一张图上
figure;
plot(x1, y1, 'b-', 'LineWidth', 1.5);
hold on;
plot(x2, y2, 'r-', 'LineWidth', 1.5);
plot(x4, y4, 'g-', 'LineWidth', 1.5);
legend('方法一：切角递推', '方法二：梯形算法', '方法三：坐标变换算法', 'Location', 'best');
title('三种方法生成的曲线');
xlabel('X坐标');
ylabel('Y坐标');
grid on;

% 绘制第二个图像：3行一列分别展示三条曲线
figure;
subplot(3,1,1);
plot(x1, y1, 'b-', 'LineWidth', 1.5);
title('方法一：切角递推');
xlabel('X坐标');
ylabel('Y坐标');
grid on;

subplot(3,1,2);
plot(x2, y2, 'r-', 'LineWidth', 1.5);
title('方法二：梯形算法');
xlabel('X坐标');
ylabel('Y坐标');
grid on;

subplot(3,1,3);
plot(x4, y4, 'g-', 'LineWidth', 1.5);
title('方法三：坐标变换算法');
xlabel('X坐标');
ylabel('Y坐标');
grid on;
