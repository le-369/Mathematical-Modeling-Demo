clc,clear,close all
x=0:0.01:1;
y=x.^3+x;
plot(x,y,'k-','DisplayName','原图像','LineWidth',1.5);
hold on
% 原始曲线方程
f = @(x) x.^3 + x;
df = @(x) 3*x.^2 + 1; % 导数
d2f = @(x) 6*x; % 二阶导数

num_points = 1000; % 用于计算弧长的点数
x = linspace(0, 1, num_points);
y = f(x);
% num_arc_samples_values = [7, 13, 5, 15, 3, 17];%3 %5 %7
num_arc_samples_values = [3,5,7, 13,  15, 17];
% 等弧长采样
for j=1:6
    s = zeros(1, num_points);
    for i = 2:num_points
        ds = sqrt((x(i) - x(i-1))^2 + (y(i) - y(i-1))^2);
        s(i) = s(i-1) + ds;
    end
    num_arc_samples =num_arc_samples_values(j) ;
    s_uniform = linspace(0, s(end), num_arc_samples);
    x_uniform = interp1(s, x, s_uniform);
    y_uniform = f(x_uniform);
    
    % 计算每个采样点的曲率
    k = abs(d2f(x_uniform)) ./ (1 + df(x_uniform).^2).^(3/2);
    %插值
    s=0:0.01:2.23;
    k1= interp1(s_uniform,k,s,'spline');  
    %始末状态
    x1(j,1)=0;
    y1(j,1)=0;
    omg(1)=deg2rad(45);
    d=0.01;
    for i=1:length(s)-1
        %方法一，切角递推
        omg(i+1)=pi/4+trapz(s(1:i+1),k1(1:i+1));
        st=0.01*k1(i);
        ds(k1(i)~=0)=2*sin(st/2)/k1(i);
        ds(k1(i)==0)=0.01;
        dx=ds*cos(omg(i)+st/2);
        dy=ds*sin(omg(i)+st/2);
        x1(j,i+1)=x1(j,i)+dx;
        y1(j,i+1)=y1(j,i)+dy;
    end
    y_1 = f(x1(j,:));
    % 计算积分误差
    error = mean(sqrt((y_1-y1(j,:)).^2));
    integral_errors(j) = error;
end

figure;
plot(num_arc_samples_values, integral_errors, 'o-','MarkerFaceColor','r','MarkerSize',6);
xlabel('采样点数量');
ylabel('MSE');
title('采样点的灵敏度分析');
grid on;

% plot(x1(j,:),y1(j,:),'-','LineWidth',1.5,'DisplayName', ['Samples: ' num2str(num_arc_samples)]);
% hold on
% end
grid on;
legend show;