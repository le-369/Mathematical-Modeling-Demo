%% 第一问
%% 1.数值
clc, clear, close all
c = 4200;
lamda01 = 1529*ones(6,1);
lamda02 = 1540*ones(6,1);
lamda1 = [1529.808; 1529.807; 1529.813; 1529.812; 1529.814; 1529.809];
lamda2 = [1541.095; 1541.092; 1541.090; 1541.093; 1541.094; 1541.091];

% 计算曲率
k1 = c * (lamda1 - lamda01) ./ lamda01;
k2 = c * (lamda2 - lamda02) ./ lamda02;

% 反转曲率方向
for i = 2:2:length(k1)
    k1(i) = k1(i) * (-1);
end
for i = 2:2:length(k2)
    k2(i) = k2(i) * (-1);
end

color1 = [0.00, 0.45, 0.74];
color2 = [0.85, 0.33, 0.10];
% 对k进行三次样条插值
t1 = 0:0.6:3;
t2 = 0:0.01:3;
k_1 = interp1(t1, k1, t2, "spline");
k_2 = interp1(t1, k2, t2,"spline");
% 绘制曲线
figure;
hold on;
plot(t2, k_1, '-', 'Color', color1, 'LineWidth', 2)
plot(t2, k_2, '--', 'Color', color1, 'LineWidth', 2)

% 绘制实心红色圆点
plot(t1, k1, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6)
plot(t1, k2, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6)

% 添加标签和网格
xlabel('弧长', 'FontSize', 12)
ylabel('曲率', 'FontSize', 12)
title('曲率随弧长的变化', 'FontSize', 14,'FontWeight', 'bold')
grid on;
legend({'k1', 'k2', '原始曲率'}, 'Location', 'Best', 'FontSize', 12)
set(gca, 'FontSize', 12)
hold off;

%% 
theta = zeros(1, length(t2));
x_reconstructed = zeros(1, length(t2));
y_reconstructed = zeros(1, length(t2));

theta(1) = deg2rad(45);
for i = 2:length(t2)
    ds = 0.01;
    theta(i) = theta(i-1) + k_2(i) * ds;
    x_reconstructed(i) = x_reconstructed(i-1) + cos(theta(i)) * ds;
    y_reconstructed(i) = y_reconstructed(i-1) + sin(theta(i)) * ds;
end

figure;
subplot(2,1,1)
plot(t2,k_2,'ro','MarkerFaceColor','r','MarkerSize',2);
title('曲率与弧长2');
xlabel('x');
ylabel('曲率k2');
grid on;
subplot(2,1,2)
plot(x_reconstructed, y_reconstructed, 'bo','MarkerFaceColor','b','MarkerSize',2);
grid on;
title('重构曲线2');
xlabel('x');
ylabel('y');
grid on;

% 计算特定位置处的曲率
x_target = [0.3, 0.4, 0.5, 0.6, 0.7];
curvature_target = zeros(size(x_target));

% 使用插值方法计算这些位置的曲率
k_interp = griddedInterpolant(x_reconstructed, k_2, 'spline', 'none');

for i = 1:length(x_target)
    curvature_target(i) = k_interp(x_target(i));
end

% 显示结果
disp('特定位置处的曲率:');
disp(table(x_target', curvature_target', 'VariableNames', {'x', 'Curvature'}));


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 定义传感器间距和初始参数
% sensor_spacing = 0.6;
% num_sensors = 6;
% initial_angle = 45 * pi / 180; % 转换为弧度
% 
% % 初始化位置和方向
% x1 = zeros(num_sensors, 1);
% y1 = zeros(num_sensors, 1);
% x2 = zeros(num_sensors, 1);
% y2 = zeros(num_sensors, 1);
% theta1 = zeros(num_sensors, 1);
% theta2 = zeros(num_sensors, 1);
% 
% % 初始位置和方向
% x1(1) = sensor_spacing * cos(initial_angle);
% y1(1) = sensor_spacing * sin(initial_angle);
% x2(1) = sensor_spacing * cos(initial_angle);
% y2(1) = sensor_spacing * sin(initial_angle);
% theta1(1) = initial_angle + k1(1) * sensor_spacing;
% theta2(1) = initial_angle + k2(1) * sensor_spacing;
% 
% % 使用曲率积分法计算位置
% for i = 2:num_sensors
%     ds = sensor_spacing;
%     theta1(i) = theta1(i-1) + k1(i) * ds;
%     theta2(i) = theta2(i-1) + k2(i) * ds;
%     x1(i) = x1(i-1) + cos(theta1(i)) * ds;
%     y1(i) = y1(i-1) + sin(theta1(i)) * ds;
%     x2(i) = x2(i-1) + cos(theta2(i)) * ds;
%     y2(i) = y2(i-1) + sin(theta2(i)) * ds;
% end
% 
% % 插值平滑曲线
% x_min = min(min(x1), min(x2));
% x_max = max(max(x1), max(x2));
% x_values = linspace(x_min, x_max, 100);
% 
% y1_interp = interp1(x1, y1, x_values, 'spline');
% y2_interp = interp1(x2, y2, x_values, 'spline');
% 
% % 计算特定 x 位置处的曲率
% x_target = [0.3, 0.4, 0.5, 0.6, 0.7];
% y1_target = interp1(x_values, y1_interp, x_target, 'spline');
% y2_target = interp1(x_values, y2_interp, x_target, 'spline');
% 
% dy1_dx = gradient(y1_interp, x_values);
% d2y1_dx2 = gradient(dy1_dx, x_values);
% dy2_dx = gradient(y2_interp, x_values);
% d2y2_dx2 = gradient(dy2_dx, x_values);
% 
% k1_target = abs(interp1(x_values, d2y1_dx2, x_target) ./ (1 + interp1(x_values, dy1_dx, x_target).^2).^(3/2));
% k2_target = abs(interp1(x_values, d2y2_dx2, x_target) ./ (1 + interp1(x_values, dy2_dx, x_target).^2).^(3/2));
% 
% % 显示结果
% disp('传感器位置和曲率:');
% disp(table(x_target', y1_target', k1_target', 'VariableNames', {'x', 'y1', '曲率1'}));
% disp(table(x_target', y2_target', k2_target', 'VariableNames', {'x', 'y2', '曲率2'}));
% 
% % 绘制曲线
% figure;
% subplot(2,1,1);
% plot(x1, y1, 'r*')
% hold on
% plot(x_values, y1_interp, 'b-');
% plot(x_target, y1_target, 'go');
% xlabel('横坐标x(m)')
% ylabel('纵坐标y(m)')
% title('传感器1 曲线重建')
% 
% subplot(2,1,2);
% plot(x2, y2, 'r*')
% hold on
% plot(x_values, y2_interp, 'b-');
% plot(x_target, y2_target, 'go');
% xlabel('横坐标x(m)')
% ylabel('纵坐标y(m)')
% title('传感器2 曲线重建')
% clc, clear, close all
% 
% % 定义变量和函数
% syms x
% f = x^3 + x; % 定义函数
% f_prime = diff(f, x); % 一阶导数
% f_double_prime = diff(f_prime, x); % 二阶导数
% 
% % 计算弧长
% arc_length_expr = sqrt(1 + f_prime^2); % 弧长表达式
% arc_length_function = matlabFunction(arc_length_expr); % 数值化表达式
% 
% % 定义弧长计算函数
% arc_length_to_x = @(x_val) integral(arc_length_function, 0, x_val);
% 
% % 计算总弧长
% total_arc_length = arc_length_to_x(1);
% 
% % 等弧长采样点
% num_points = 6; % 采样点数
% sample_points_x = zeros(num_points, 1);
% sample_points_x(1) = 0;
% 
% for i = 2:num_points
%     target_length = (i-1) * (total_arc_length / (num_points-1));
%     sample_points_x(i) = fzero(@(x_val) arc_length_to_x(x_val) - target_length, [sample_points_x(i-1), 1]);
% end
% 
% % 计算曲率
% curvature_function = matlabFunction(abs(f_double_prime) / (1 + f_prime^2)^(3/2));
% curvatures = arrayfun(curvature_function, sample_points_x);
% 
% % 递推算法计算曲线位置
% s = sample_points_x; % 弧长s
% k = curvatures; % 曲率k
% delta_s = total_arc_length / (num_points - 1); % 弧长的增量




