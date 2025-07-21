clc;
clear;

minc = inf;
mc = -inf;
km = 0;
kmi = 0;

lr = 1.2; % 后轮轴到汽车质心的距离，米
lf = 1.2; % 前轮轴到汽车质心的距离，米
V = 5 * 1000 / 3600; % 速度，米/秒
w = 1.84; % 汽车宽度，米

t_span = [0, 100]; % 模拟时间段，秒
initial_conditions = [0, 0, pi/2]; % 初始条件 [X0, Y0, psi0]


num_runs = 10;
solutions1 = zeros(num_runs, 2);
solutions2 = zeros(num_runs, 2);
for n = 1:num_runs
% 蒙特卡洛模拟循环
    for i = 1:1000
        delta_f = rand(1) * pi/4; % 前轮的随机转向角度，弧度
        k = rand(1) * 5; % 随机距离
    
        % 使用ode45求解微分方程
        [~, Y] = ode45(@(t, Y) car_model(t, Y, V, delta_f, lr, lf), t_span, initial_conditions);
    
        X = Y(:, 1);
        Y_pos = Y(:, 2);
        psi = Y(:, 3);
    
        % 计算所有四个轮子的轨迹
        FL_x = X + lf * cos(psi) - w/2 * sin(psi);
        FL_y = Y_pos + lf * sin(psi) + w/2 * cos(psi);
    
        FR_x = X + lf * cos(psi) + w/2 * sin(psi);
        FR_y = Y_pos + lf * sin(psi) - w/2 * cos(psi);
    
        RL_x = X - lr * cos(psi) - w/2 * sin(psi);
        RL_y = Y_pos - lr * sin(psi) + w/2 * cos(psi);
    
        RR_x = X - lr * cos(psi) + w/2 * sin(psi);
        RR_y = Y_pos - lr * sin(psi) - w/2 * cos(psi);
    
        % % 找到水平的n值
        % for n= 1:length(X)
        %     if abs(FL_y(n)-RL_y(n))<0.1
        %         break;
        %     end
        % end
    
        % 检查碰撞条件
        pd = 0; % 碰撞指示器
        for j = 1:length(X)
            % 如果右前轮太远
            if FR_y(j) > 8.7 - k
                pd = 1; % 碰撞
                break;
            end
            % 如果左后轮
            if abs(RL_x(j)+1.2)<0.1
                if RL_y(j) < 2.1 - k
                    pd = 1; % 碰撞
                    break;
                end
            end
        end
    
        % 如果没有碰撞，更新最小和最大转向角度
        if pd == 0
            if delta_f > mc
                mc = delta_f;
                km = k;
            end
            if delta_f < minc
                minc = delta_f;
                kmi = k;
            end
        end
    end

    solutions1(n, :) = [km,mc];
    solutions2(n, :) = [kmi,minc];
end

% 检查解的稳定性
mean_solution1 = mean(solutions1);
std_solution1 = std(solutions1);
mean_solution2 = mean(solutions2);
std_solution2 = std(solutions2);


disp(['平均解: 直行距离 = ', num2str(mean_solution1(1)), ', 转弯角度 = ', num2str(rad2deg(mean_solution1(2))), ' 度']);
disp(['解的标准差: 直行距离 = ', num2str(std_solution1(1)), ', 转弯角度 = ', num2str(rad2deg(std_solution1(2))), ' 度']);
disp(['平均解: 直行距离 = ', num2str(mean_solution2(1)), ', 转弯角度 = ', num2str(rad2deg(mean_solution2(2))), ' 度']);
disp(['解的标准差: 直行距离 = ', num2str(std_solution2(1)), ', 转弯角度 = ', num2str(rad2deg(std_solution2(2))), ' 度']);



% % 显示结果
% disp(['最小转向角度（度）: ', num2str(rad2deg(minc))]);
% disp(['最大转向角度（度）: ', num2str(rad2deg(mc))]);
% disp(['最小角度对应的距离: ', num2str(kmi)]);
% disp(['最大角度对应的距离: ', num2str(km)]);



   






