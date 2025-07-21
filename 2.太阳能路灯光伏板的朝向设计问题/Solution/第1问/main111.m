clc, clear, close all

%% 每个月15号
date = [14, 46, 74, 105, 135, 166, 196, 227, 258, 288, 319, 349];
% 大气透过率
KL = 0.5553;
% 当地纬度
latitude = 30 + 35/60;
fai = deg2rad(latitude);
longitude = 114 + 19/60;
% fai = deg2rad(30.58);
% 大气层外太阳辐射强度(W/m²)
I0 = [1405, 1394, 1378, 1353, 1334, 1316, 1308, 1315, 1330, 1350, 1372, 1392];
% 时间序列(h)
time = 6:0.5:19;
time = time';
% 太阳时角(弧度)
omega =  deg2rad(15 * (time - 12));

% 光伏板的倾角
beta = [10,20,30];
beta = deg2rad(beta);

% 朝向角从东到南再到西(弧度)
azimuth = deg2rad(1:1:360);

% 结果存储
max_I_B = zeros(12, length(azimuth), length(beta));
total_energy = zeros(12,length(azimuth),length(beta));

% 太阳赤纬角，太阳高度角和太阳方位角
delta = zeros(12,1);
alpha = zeros(12,27);
r_s = zeros(12,27);
I_DN = zeros(12,27);
I_B = zeros(3,27);
for i = 1:12
    n = date(i);
    % 第i个月的太阳赤纬角(弧度)
    delta(i) = deg2rad(23.45 * sin((2*pi/365)*(n+284)));
    % 太阳高度角
    alpha(i,:) = asin(cos(delta(i))*cos(fai)*cos(omega) + sin(delta(i))*sin(fai));
    % 太阳方位角
    % r_s(i,:) = acos((sin(delta(i)-sin(alpha(i,:)).*sin(fai)) ./ (cos(alpha(i,:)).*cos(fai))));
    phi_s_temp = acos((sin(delta(i)) - sin(alpha(i, :)) * sin(fai)) ./ (cos(alpha(i, :)) * cos(fai)));
    phi_s = phi_s_temp;
    phi_s(omega >= 0) = 2 * pi - phi_s_temp(omega >= 0);
    r_s(i, :) = phi_s;

    % 地面直射强度
    for j = 1:27
        if alpha(i,j) > 0
            I_DN(i,j) = I0(i) .* exp(-KL ./ sin(alpha(i,j)));
        end
    end
    
    % 计算不同方位角和倾斜角度下的辐射强度
    for a = 1:length(azimuth)
        for k = 1:length(beta)
            % 不同倾斜角度下的辐射强度
            I_B(i,:) = I_DN(i,:) .* abs(sin(alpha(i,:)) .* cos(beta(k)) + cos(alpha(i,:)) .* sin(beta(k)) .* cosd(rad2deg(r_s(i,:))-rad2deg(azimuth(a))));
            % I_B(i,:) = I_DN(i,:) .* abs(cos(alpha(i,:)).*cos(r_s(i,:)).*sin(beta(k)).*cos(azimuth(a)) + cos(alpha(i,:)).*sin(azimuth(a)).*sin(beta(k)).*sin(r_s(i,:)) + sin(alpha(i,:)).*cos(beta(k)));
            max_I_B(i, a, k) = max(I_B(i,:));
            total_energy(i,a,k) = trapz(time, I_B(i,:)*3600);
        end
    end
end

% 绘制结果
figure(1);
for k = 1:length(beta)
    subplot(length(beta), 1, k);
    hold on;
    for i = 1:12
        plot(rad2deg(azimuth), max_I_B(i, :, k),'LineWidth',1);
        xlim([0,360]);
    end
    hold off;
    xlabel('朝向角 (度)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('最大辐射强度 (W/m²)', 'FontSize', 12, 'FontWeight', 'bold');
    title(['光伏板倾角 ', num2str(rad2deg(beta(k))), '° 时的最大太阳辐射强度'], 'FontSize', 14, 'FontWeight', 'bold');
    legend(arrayfun(@(x) ['第', num2str(x), '个月'], 1:12, 'UniformOutput', false));
end
figure(2);
for k = 1:length(beta)
    subplot(length(beta), 1, k);
    hold on;
    for i = 1:12
        plot(rad2deg(azimuth), total_energy(i, :, k),'LineWidth',1);
        xlim([0,360]);
    end
    hold off;
    xlabel('朝向角 (度)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('辐射总能量 (J)', 'FontSize', 12, 'FontWeight', 'bold');
    title(['光伏板倾角 ', num2str(rad2deg(beta(k))), '° 时的太阳辐射总能量'], 'FontSize', 14, 'FontWeight', 'bold');
    legend(arrayfun(@(x) ['第', num2str(x), '个月'], 1:12, 'UniformOutput', false));
end
