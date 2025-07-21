%%%%%%%%%%%%%%%%%%%%%%%%%%%%   计算不同纬度范围的最优朝向    %%%%%%%%%%%%%%%%
clc, clear;
latitude = 30 + 35/60;
fitnessfcn = @(x) fun(x, latitude);
nvars = 2;
lb = [0, 3*pi/4]; % 下界
ub = [pi/2, 5*pi/4]; % 上界
options = optimoptions('gamultiobj', 'PopulationSize', 100, 'MaxGenerations', 300);
[x, fval] = gamultiobj(fitnessfcn, nvars, [], [], [], [], lb, ub, options);
% 结果提取
figure;
numSolutions = size(fval, 1);
colors = lines(numSolutions); % 使用默认的 colormap 为每个解生成不同的颜色

% 第一个子图：储电效率与储电量关系
subplot(2, 1, 1);
hold on;
for i = 1:numSolutions
    scatter(-fval(i, 1), -fval(i, 2), 50, 'filled', 'MarkerFaceColor', colors(i, :));
end
xlabel('日均太阳直射辐射时长/时', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('日均太阳辐射总能量/kJ', 'FontSize', 12, 'FontWeight', 'bold');
title('当前纬度最优储电效率与储电量关系', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
set(gca, 'GridLineStyle', '--', 'GridColor', 'k', 'GridAlpha', 0.3);
legend(arrayfun(@(x) sprintf('解 %d', x), 1:numSolutions, 'UniformOutput', false), 'Location', 'best');
hold off;

% 第二个子图：倾角与方位角关系
subplot(2, 1, 2);
hold on;
for i = 1:numSolutions
    scatter(rad2deg(x(i, 1)), rad2deg(x(i, 2)), 50, 'filled', 'MarkerFaceColor', colors(i, :));
end
xlabel('倾角/°', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('方位角/°', 'FontSize', 12, 'FontWeight', 'bold');
title('当前纬度最优倾角与方位角', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
set(gca, 'GridLineStyle', '--', 'GridColor', 'k', 'GridAlpha', 0.3);
legend(arrayfun(@(x) sprintf('解 %d', x), 1:numSolutions, 'UniformOutput', false), 'Location', 'best');
hold off;


%x(1)倾角，x(2)方位角
%y(1)储电效率，y（2）储电量
% 定义纬度范围
% latitude_ranges = [0, 10; 10, 20; 20, 30; 30, 40; 40, 50; 50, 60;60,70;70,80;80,90];
% num_ranges = size(latitude_ranges, 1);
% 
% % 预分配结果矩阵
% results = zeros(num_ranges, 5);
% 
% % 设置Excel文件名
% filename = 'OptimizationResults.xlsx';
% 
% for range_idx = 1:num_ranges
%     lat_min = latitude_ranges(range_idx, 1);
%     lat_max = latitude_ranges(range_idx, 2);
%     lat_mean = mean([lat_min, lat_max]);
% 
%     % 定义优化问题
%     fitnessfcn = @(x) fun(x, lat_mean);
%     nvars = 2;
%     lb = [0, 3*pi/4]; % 下界
%     ub = [pi/2, 5*pi/4]; % 上界
%     options = optimoptions('gamultiobj', 'PopulationSize', 100, 'MaxGenerations', 300);
%     [x, fval] = gamultiobj(fitnessfcn, nvars, [], [], [], [], lb, ub, options);
% 
%     % 计算平均值
%     avg_tilt_angle = mean(rad2deg(x(:, 1)));
%     avg_azimuth_angle = mean(rad2deg(x(:, 2)));
%     avg_efficiency = -mean(fval(:, 1));
%     avg_energy = -mean(fval(:, 2));
% 
%     % 保存结果
%     results(range_idx, :) = [lat_mean, avg_tilt_angle, avg_azimuth_angle, avg_efficiency, avg_energy];
% end

% % 写入Excel文件
% header = {'纬度范围', '最优倾角', '最优方向角', '储电效率', '储电量'};
% xlswrite(filename, [header; num2cell(results)]);