% %% 第一问
% clc,clear,close all
% % 每个月15号
% date = [14,46,74,105,135,166,196,227,258,288,319,349];
% % 大气透过率
% KL = 0.5553;
% % 当地维度
% latitude = 30 + 35/60;
% fai = deg2rad(latitude);
% % 大气层外太阳辐射强度(W/m²)
% I0 = [1405,1394,1378,1353,1334,1316,1308,1315,1330,1350,1372,1392];
% % 时间序列(h)
% time = 6:0.5:19;
% time = time';
% % 太阳时角(弧度)
% omega =  deg2rad(15 * (time - 12));
% 
% % 每月15日的太阳赤纬角
% delta = zeros(12,1);
% alpha = zeros(12,27);
% r_s = zeros(12,27);
% I_DN = zeros(12,27);
% 
% for i = 1:12
%     n = date(i);
%     % 第i个月的太阳赤纬角(弧度)
%     delta(i) = deg2rad(23.45 * sin((2*pi/365)*(n+284)));
%     % 太阳高度角
%     alpha(i,:) = asin(cos(delta(i))*cos(fai)*cos(omega) + sin(delta(i))*sin(fai));
%     % 太阳方位角
%     phi_s_temp = acos((sin(delta(i)) - sin(alpha(i, :)) * sin(fai)) ./ (cos(alpha(i, :)) * cos(fai)));
%     phi_s = phi_s_temp;
%     phi_s(omega >= 0) = 2 * pi - phi_s_temp(omega >= 0);
%     r_s(i, :) = phi_s;
% 
%     % 地面直射强度
%     for j = 1:27
%         if alpha(i,j) > 0
%             I_DN(i,j) = I0(i) .* exp(-KL ./ sin(alpha(i,j)));
%         end
%     end
% 
%     % 光伏板的倾角
%     beta = [20,40,60];beta = deg2rad(beta);
% 
%     I_B = zeros(3,27);
%     % 不同倾斜角度下的辐射强度和总辐射能量
%     for k = 1:length(beta)
%         I_B(k,:) = I_DN(i,:) .* abs(sin(alpha(i,:)) .* cos(beta(k)) - cos(alpha(i,:)) .* sin(beta(k)) .* cos(r_s(i,:)));
%         E = trapz(time,I_B(k,:)*3600);
%         fprintf('第%d个月光伏板倾角 %d° 时的最大太阳直射强度:%.2f W/m²\n',i,rad2deg(beta(k)),max(I_B(k,:)));
%         fprintf('第%d个月光伏板倾角 %d° 时的太阳直射辐射总能量：%.2f J\n\n', i,rad2deg(beta(k)), E/100000);
%     end
% end

% 问题结果分析
% clc, clear, close all
%% 每个月15号
date = [14, 46, 74, 105, 135, 166, 196, 227, 258, 288, 319, 349];
% 大气透过率
KL = 0.5553;
% 当地纬度
latitude = 30 + 35/60;
fai = deg2rad(latitude);
% 大气层外太阳辐射强度(W/m²)
I0 = [1405, 1394, 1378, 1353, 1334, 1316, 1308, 1315, 1330, 1350, 1372, 1392];
% 时间序列(h)
time = 6:0.5:19;
time = time';
% 太阳时角(弧度)
omega =  deg2rad(15 * (time - 12));

% 光伏板的倾角
beta = [20, 40, 60];
beta = deg2rad(beta);

% 初始化存储变量
max_intensity = zeros(12, 3);
total_energy = zeros(12, 3);
delta = zeros(12,1);
alpha = zeros(12,27);
r_s = zeros(12,27);
I_DN = zeros(12,27);
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

    % 地面直射强度
    for j = 1:27
        if alpha(i,j) > 0
            I_DN(i,j) = I0(i) .* exp(-KL ./ sin(alpha(i,j)));
        end
    end

    I_B = zeros(3,27);
    % 计算不同倾斜角度下的辐射强度和总辐射能量
    for k = 1:length(beta)
        I_B(i,:) = I_DN(i,:) .* abs(sin(alpha(i,:)) .* cos(beta(k)) - cos(alpha(i,:)) .* sin(beta(k)) .* cos(r_s(i,:)));
        max_intensity(i, k) = max(I_B(i,:));
        total_energy(i, k) = trapz(time, I_B(i,:)*3600);
    end
end

% 绘制最大太阳直射强度变化情况
figure;
for k = 1:length(beta)
    subplot(3,1,k);
    plot(1:12, max_intensity(:, k), '-s','Color','#D95319','LineWidth',2);
    title(['每月15日最大太阳直射强度 (倾角 ' num2str(rad2deg(beta(k))) '°)'], 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('月份', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('强度 (W/m²)', 'FontSize', 12, 'FontWeight', 'bold');
    xlim([1,12])
    grid on;
end

% 绘制总辐射能量变化情况
figure;
for k = 1:length(beta)
    subplot(3,1,k);
    plot(1:12, total_energy(:, k), '-h','Color','#A2142F','LineWidth',2);
    title(['每月15日太阳直射辐射总能量 (倾角 ' num2str(rad2deg(beta(k))) '°)'], 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('月份', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('能量 (J)', 'FontSize', 12, 'FontWeight', 'bold');
    xlim([1,12])
    grid on;
end
%% 每个月15号
% date = [14, 46, 74, 105, 135, 166, 196, 227, 258, 288, 319, 349];
% % 大气透过率
% KL = 0.5553;
% 
% latitude = 30 + 35/60;
% fai = deg2rad(latitude);
% % 大气层外太阳辐射强度(W/m²)
% I0 = [1405, 1394, 1378, 1353, 1334, 1316, 1308, 1315, 1330, 1350, 1372, 1392];
% % 时间序列(h)
% time = 6:0.5:19;
% time = time';
% % 太阳时角(弧度)
% omega =  deg2rad(15 * (time - 12));
% 
% % 光伏板的倾角从0到90度变化
% beta_range = 0:1:50;
% beta_range_rad = deg2rad(beta_range);
% 
% % 初始化存储变量
% max_intensity = zeros(12, length(beta_range));
% total_energy = zeros(12, length(beta_range));
% delta = zeros(12,1);
% alpha = zeros(12,27);
% r_s = zeros(12,27);
% I_DN = zeros(12,27);
% % zs = 90;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  使用75°来测试倾角
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% % p = deg2rad(70);
% for i = 1:12
%     n = date(i);
%      % 第i个月的太阳赤纬角(弧度)
%     delta(i) = deg2rad(23.45 * sin((2*pi/365)*(n+284)));
%     % 太阳高度角
%     alpha(i,:) = asin(cos(delta(i))*cos(fai)*cos(omega) + sin(delta(i))*sin(fai));
%     % 太阳方位角
%     phi_s_temp = acos((sin(delta(i)) - sin(alpha(i, :)) * sin(fai)) ./ (cos(alpha(i, :)) * cos(fai)));
%     phi_s = phi_s_temp;
%     phi_s(omega >= 0) = 2 * pi - phi_s_temp(omega >= 0);
%     r_s(i, :) = phi_s;
% 
%     % 地面直射强度
%     for j = 1:27
%         if alpha(i,j) > 0
%             I_DN(i,j) = I0(i) .* exp(-KL ./ sin(alpha(i,j)));
%         end
%     end
%     I_B = zeros(3,27);
%     % 计算不同倾斜角度下的辐射强度和总辐射能量
%     for k = 1:length(beta_range_rad)
%         I_B(i,:) = I_DN(i,:) .* abs(sin(alpha(i,:)) .* cos(beta_range_rad(k)) - cos(alpha(i,:)) .* sin(beta_range_rad(k)) .* cos(r_s(i,:)));
%         % I_B(i,:) = I_DN(i,:) .* abs(cos(alpha(i,:)).*cos(r_s(i,:)).*sin(beta_range_rad(k)).*cos(p) + cos(alpha(i,:)).*sin(p).*sin(beta_range_rad(k)).*sin(r_s(i,:)) + sin(alpha(i,:)).*cos(beta_range_rad(k)));
%         max_intensity(i, k) = max(I_B(i,:));
%         total_energy(i, k) = trapz(time, I_B(i,:)*3600);
%     end
% end
% 
% % 绘制最大太阳直射强度变化情况
% figure(1);
% for i = 1:12
%     plot(beta_range, max_intensity(i, :), 'LineWidth', 2);
%     hold on;
% end
% title('最大太阳直射强度随倾角变化', 'FontSize', 14, 'FontWeight', 'bold');
% xlabel('倾角 (度)', 'FontSize', 12, 'FontWeight', 'bold');
% ylabel('最大太阳直射强度 (W/m²)', 'FontSize', 12, 'FontWeight', 'bold');
% legend('1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月', 'Location', 'Best');
% figure(2);
% for k = 1:12
%     plot(beta_range, total_energy(k,:),'LineWidth',2);
%     hold on;
% end
% title('太阳直射辐射总能量随倾角的变化','FontSize', 14, 'FontWeight', 'bold');
% xlabel('倾角 (度)', 'FontSize', 12, 'FontWeight', 'bold');
% ylabel('太阳直射辐射总能量 (J)', 'FontSize', 12, 'FontWeight', 'bold');
% legend('1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月', 'Location', 'Best');
% grid on;
% hold off;


