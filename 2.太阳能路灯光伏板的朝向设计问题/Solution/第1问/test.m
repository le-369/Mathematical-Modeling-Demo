clc; clear;

% 纬度（北纬30度35分）
latitude = 30 + 35/60;
latitude_rad = deg2rad(latitude);

% 每月的赤纬角数据
delta_deg = [-21.4363, -13.2892, -2.8189, 9.4149, 18.7919, 23.3144, 21.5173, 13.7836, 2.2169, -9.5994, -19.1478, -23.3352];
delta_rad = deg2rad(delta_deg);

% 时间序列（小时）
time = 6:0.5:19;
omega_deg = 15 * (time - 12);
omega_rad = deg2rad(omega_deg);

% 计算太阳高度角
alpha_deg = zeros(length(delta_rad), length(time));

for i = 1:length(delta_rad)
    delta = delta_rad(i);
    alpha_deg(i, :) = rad2deg(asin(sin(delta) * sin(latitude_rad) + cos(delta) * cos(latitude_rad) * cos(omega_rad)));
end

% 绘制结果
figure;
hold on;
colors = jet(length(delta_rad));
for i = 1:length(delta_rad)
    plot(time, alpha_deg(i, :), 'Color', colors(i, :), 'DisplayName', sprintf('Month %d', i));
end
xlabel('时间（小时）');
ylabel('太阳高度角（度）');
title('不同月份太阳高度角的变化');
legend('show');
grid on;
hold off;
