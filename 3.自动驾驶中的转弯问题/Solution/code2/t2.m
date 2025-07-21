%%速度进行灵敏度分析
% clc;
% clear;
% close all;
% 
% % 定义已知参数
% lr = 1.2; % 后轮到车重心的距离，单位：m
% lf = 1.2; % 前轮到车重心的距离，单位：m
% delta_f = deg2rad(30); % 前轮偏角，单位：弧度
% w = 1.84; % 汽车宽度，单位：m
% 
% % 初始条件 [X0, Y0, psi0]
% initial_conditions = [0, 0, pi/2];
% 
% % 定义时间范围
% t_span = [0, 1]; % 模拟5秒
% 
% 定义不同的速度进行灵敏度分析
% v = linspace(10, 50, 5) * 1000 / 3600; % 速度范围，单位：m/s
% 
% 
% 
% % 使用ODE求解器求解轨迹
% [t0, Y0] = ode45(@(t, Y) car_model(t, Y, v(1), delta_f, lr, lf), t_span, initial_conditions);
% 
% % 提取初始结果
% X0 = Y0(:, 1);
% Y_pos0 = Y0(:, 2);
% % 循环不同的速度值
% for k = 1:length(v)
%     V = v(k);
    % % 使用ODE求解器求解轨迹
%     [t, Y] = ode45(@(t, Y) car_model(t, Y, V, delta_f, lr, lf), t_span, initial_conditions);
% 
% %     提取结果
%     X = Y(:, 1);
%     Y_pos = Y(:, 2);
%     plot(X, Y_pos, '-o','DisplayName',num2str(k));
%     hold on
% 
% end
% legend show
% %速度越大转弯半径越大，但速度总体对路径影响不大，


%对角度进行灵敏度分析
clc;
clear;
close all;

% 定义已知参数
lr = 1.2; % 后轮到车重心的距离，单位：m
lf = 1.2; % 前轮到车重心的距离，单位：m
delta_f = deg2rad(linspace(10, 50, 5)); % 前轮偏角，单位：弧度
w = 1.84; % 汽车宽度，单位：m

% 初始条件 [X0, Y0, psi0]
initial_conditions = [0, 0, pi/2];

% 定义时间范围
t_span = [0:0.1:100]; % 模拟5*20秒

% 定义不同的速度进行灵敏度分析
v = 3 * 1000 / 3600; % 速度范围，单位：m/s
for k = 1:length(delta_f)
    V = v;

    % 使用ODE求解器求解轨迹
    [t, Y] = ode45(@(t, Y) car_model(t, Y, V, delta_f(k), lr, lf), t_span, initial_conditions);

    % 提取结果
    X = Y(:, 1);
    Y_pos = Y(:, 2);
    plot(X, Y_pos,'DisplayName','转弯角度 = ',num2str(rad2deg(delta_f(k))),'度');
    hold on

end
legend show

%转弯角越大转弯半径越小，转弯角对路径影响比较大；

