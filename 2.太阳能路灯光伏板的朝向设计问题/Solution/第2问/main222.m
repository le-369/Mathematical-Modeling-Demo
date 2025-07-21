%% 使用梯度下降策略求解
clc, clear, close all

% 参数初始化
date = [14,46,74,105,135,166,196,227,258,288,319,349]; % 每个月的15号
KL = 0.5553; % 大气透过率
latitude = 30 + 35/60; % 当地纬度
fai = deg2rad(latitude);
I0 = [1405,1394,1378,1353,1334,1316,1308,1315,1330,1350,1372,1392]; % 大气层外太阳辐射强度(W/m²)
time = 6:0.5:19; % 时间序列(h)
time = time';
omega = deg2rad(15 * (time - 12)); % 太阳时角(弧度)
delta = zeros(12,1); % 赤纬角
alpha = zeros(12,27); % 太阳高度角
r_s = zeros(12,27); % 太阳方位角
I_DN = zeros(12,27); % 地面直射强度

% 梯度下降参数
learning_rate = 1e-8; % 学习率
num_iterations = 1000; % 迭代次数
azimuth = deg2rad(180); % 初始朝向角
beta = deg2rad(26); % 初始倾角

% 梯度下降过程
for iter = 1:num_iterations
    grad_azimuth = 0;
    grad_beta = 0;
    total_E = 0;
    
    for i = 1:12
        n = date(i);
        % 第i个月的太阳赤纬角(弧度)
        delta(i) = deg2rad(23.45 * sin((2*pi/365)*(n+284)));
        % 太阳高度角
        alpha(i,:) = asin(cos(delta(i))*cos(fai)*cos(omega) + sin(delta(i))*sin(fai));
        % 太阳方位角
        phi_s_temp = acos((sin(delta(i)) - sin(alpha(i, :)) * sin(fai)) ./ (cos(alpha(i, :)) * cos(fai)));
        phi_s = phi_s_temp;
        phi_s(omega >= 0) = 2 * pi - phi_s_temp(omega >= 0);
        r_s(i, :) = phi_s;

        for j = 1:27
            if alpha(i,j) > 0
                I_DN(i,j) = I0(i) .* exp(-KL ./ sin(alpha(i,j))); % 地面直射强度
            end
        end

        % 计算直射太阳板的强度(考虑到了余弦损失)
        I_B = I_DN(i,:) .* abs(sin(alpha(i,:)) .* cos(beta) + cos(alpha(i,:)) .* sin(beta) .* cosd(rad2deg(r_s(i,:))-rad2deg(azimuth)));
        % 累积当天的能量值
        E = trapz(time,I_B*3600)/1000;
        total_E = total_E + E; % 累加每个月的能量值
        
        % 计算梯度
        grad_azimuth = grad_azimuth + sum(I_DN(i,:) .* (sind(rad2deg(r_s(i,:))-rad2deg(azimuth))));
        grad_beta = grad_beta + sum(I_DN(i,:) .* (-sin(alpha(i,:)) .* sin(beta) + cos(alpha(i,:)) .* cos(beta) .* cosd(rad2deg(r_s(i,:))-rad2deg(azimuth))));
    end
    
    % 更新参数
    azimuth = azimuth - learning_rate * grad_azimuth;
    beta = beta - learning_rate * grad_beta;
end

% 输出最优结果
fprintf('最优固定倾角为：%.2f°\n', rad2deg(beta));
fprintf('最优固定朝向角为：%.2f°\n', rad2deg(azimuth));
fprintf('日均最大总能量为：%.2f\n', total_E/12);
