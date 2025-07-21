clc,clear;
close all;
% 原始曲线方程
f = @(x) x.^3 + x;
df = @(x) 3*x.^2 + 1; % 导数
d2f = @(x) 6*x; % 二阶导数

num_points = 1000; % 用于计算弧长的点数
x = linspace(0, 1, num_points);
y = f(x);

% 计算总弧长
s = zeros(1, num_points);
for i = 2:num_points
    ds = sqrt((x(i) - x(i-1))^2 + (y(i) - y(i-1))^2);
    s(i) = s(i-1) + ds;
end

% 等弧长采样
num_arc_samples = 10;
s_uniform = linspace(0, s(end), num_arc_samples);
x_uniform = interp1(s, x, s_uniform);
y_uniform = f(x_uniform);

% 计算每个采样点的曲率
k = abs(d2f(x_uniform)) ./ (1 + df(x_uniform).^2).^(3/2);


plot(x_uniform,y_uniform,'bo','MarkerFaceColor','b','MarkerSize',6)
hold on;
%% 原图像
x=0:0.01:1;
y=x.^3+x;
plot(x,y,'r-', 'LineWidth', 1.5);
xlabel('x')
ylabel('y')
hold on
legend('原始图像y=x^3+x', '采样点')

%插值
% s=0:0.01:2.23;
s = 0:0.01:s(end);
k1= interp1(s_uniform,k,s,'spline');  
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
    %1. 方法一，切角递推
    omg(i+1)=pi/4+trapz(s(1:i+1),k1(1:i+1));
    st=0.01*k1(i);
    ds(k1(i)~=0)=2*sin(st/2)/k1(i);
    ds(k1(i)==0)=0.01;
    dx=ds*cos(omg(i)+st/2);
    dy=ds*sin(omg(i)+st/2);
    x1(i+1)=x1(i)+dx;
    y1(i+1)=y1(i)+dy;
    
    %2. 方法二，通过梯形算法解曲率积分求得曲线位置
    fx(i+1)=cos(omg(i+1));
    fy(i+1)=sin(omg(i+1));
    x2(i+1)=trapz(s(1:i+1),fx(1:i+1));
    y2(i+1)=trapz(s(1:i+1),fy(1:i+1));
  
    %3. 方法三坐标变换算法
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

    %4. 方法四斜率递推算法
    kk(i+1)=tan(k1(i)*d+atan(kk(i)));
    x3(i+1)=x3(i)+d/sqrt(1+kk(i)^2);
    y3(i+1)=y3(i)+kk(i)*d/sqrt(1+kk(i)^2);
end
color1 = [250, 44, 123] / 255;
color2 = [5,248,214] / 255;
color3 = [255, 162, 53] / 255;
color4 = [4, 197, 243] / 255;
%%
% % 绘制第一个图像：三个曲线展示在一张图上
% figure;
% plot(x1, y1, 'Color', color1, 'LineWidth', 1.5);
% hold on;
% plot(x2, y2, 'Color', color2, 'LineWidth', 1.5);
% plot(x4, y4, 'Color', color3, 'LineWidth', 1.5);
% plot(x3, y3, 'Color', color4, 'LineWidth', 1.5);
% legend('方法一：切角递推', '方法二：梯形算法','方法三：坐标变换算法','方法四：斜率递推', 'Location', 'best');
% title('四种方法生成的曲线');
% xlim([0,1])
% ylim([0,2])
% xlabel('X坐标');
% ylabel('Y坐标');
% grid on;

%% 误差分析
% 计算每种方法的误差
y_1=f(x1);
y_2=f(x2);
y_3=f(x3);
y_4=f(x4);

errors_method1 = sqrt((y_1 - y1).^2);
errors_method2 = sqrt((y_2 - y2).^2);
errors_method3 = sqrt((y_3 - y3).^2);
errors_method4 = sqrt((y_4 - y4).^2);
% errors_method1 = abs((y_1 - y1).^2);
% errors_method2 = abs((y_2 - y2).^2);
errors_method3_ = mean(abs((y_4 - y4).^2));

% 计算平均误差
avg_error_method1 = mean(errors_method1);
avg_error_method2 = mean(errors_method2);
avg_error_method3 = mean(errors_method3);
avg_error_method4 = mean(errors_method4);

fprintf('平均误差:\n');
fprintf('方法一: %.10f\n', avg_error_method1);
fprintf('方法二: %.10f\n', avg_error_method2);
fprintf('方法三: %.10f\n', avg_error_method4);
fprintf('方法四: %.10f\n', avg_error_method3);

%残差平方和
sse1=sum((y_1 - y1).^2);
sse2=sum((y_2 - y2).^2);
sse3=sum((y_3 - y3).^2);
sse4=sum((y_4 - y4).^2);

%对总平方和
sst1=sum((y_1 - mean(y_1)).^2);
sst2=sum((y_2 - mean(y_2)).^2);
sst3=sum((y_3 - mean(y_3)).^2);
sst4=sum((y_4 - mean(y_4)).^2);

%回归平方和
ssr1=sum((y1 - mean(y_1)).^2);
ssr2=sum((y2 - mean(y_2)).^2);
ssr3=sum((y3 - mean(y_3)).^2);
ssr4=sum((y4 - mean(y_4)).^2);

%拟合优度R^2
R1=ssr1/sst1;
R2=ssr2/sst2;
R3=ssr3/sst3;
R4=ssr4/sst4;

fprintf('拟合优度:\n');
fprintf('方法一: %.4f\n', R1);
fprintf('方法二: %.4f\n', R2);
fprintf('方法三: %.4f\n', R4);
fprintf('方法四: %.4f\n', R3);

% 绘制误差分布
figure(1);
subplot(4, 1, 1);
plot(x1, errors_method1, 'Color', color1, 'LineWidth', 1.5);
title('方法一误差分布','FontSize',14,'FontWeight','bold');
xlabel('x','FontSize',12);
ylabel('误差','FontSize',12);
grid on;
subplot(4, 1, 2);
plot(x2, errors_method2, 'Color', color2, 'LineWidth', 1.5);
title('方法二误差分布','FontSize',14,'FontWeight','bold');
xlabel('x','FontSize',12);
ylabel('误差','FontSize',12);
grid on;
subplot(4, 1, 3);
plot(x4, errors_method4, 'Color', color3,'LineWidth', 1.5);
title('方法三误差分布','FontSize',14,'FontWeight','bold');
xlabel('x','FontSize',12);
xlim([0,1])
ylabel('误差','FontSize',12);
grid on;
subplot(4, 1, 4);
plot(x3, errors_method3, 'Color', color4,'LineWidth', 1.5);
title('方法四误差分布','FontSize',14,'FontWeight','bold');
xlabel('x','FontSize',12);
xlim([0,1])
ylabel('误差','FontSize',12);
grid on;
sgtitle('拟合曲线误差分析','FontSize',14,'FontWeight','bold');

figure(2);
plot(x1, errors_method1, 'Color', color1, 'LineWidth', 1.5);
hold on
plot(x2, errors_method2, 'Color', color2, 'LineWidth', 1.5);
hold on
plot(x4, errors_method4, 'Color', color3, 'LineWidth', 1.5);
hold on
plot(x3, errors_method3, 'Color', color4, 'LineWidth', 1.5);
title('误差分布','FontSize',14,'FontWeight','bold');
xlabel('x','FontSize',12);
ylabel('误差','FontSize',12);
xlim([0,1])
legend('方法一：切角递推误差', '方法二：梯形算法误差','方法三：坐标变换算法','方法四：斜率递推误差', 'Location', 'best');
grid on;





