% %% 验证
% %% 每个月15号
% date = [14, 46, 74, 105, 135, 166, 196, 227, 258, 288, 319, 349];
% % 大气透过率
% KL = 0.5553;
% % 当地纬度
% fai = deg2rad(30.58);
% % 大气层外太阳辐射强度(W/m²)
% I0 = [1405, 1394, 1378, 1353, 1334, 1316, 1308, 1315, 1330, 1350, 1372, 1392];
% % 时间序列(h)
% time = 6:0.5:19;
% time = time';
% % 太阳时角(弧度)
% omega = pi/12 * (time - 12);
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
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  使用75°来测试倾角
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% p = deg2rad(70);
% for i = 1:12
%     n = date(i);
%     % 第i个月的太阳赤纬角(弧度)
%     delta(i) = deg2rad(23.45 * sind((360/365)*(n-81)));
%     % 太阳高度角
%     alpha(i,:) = asin(cos(delta(i))*cos(fai)*cos(omega) + sin(delta(i))*sin(fai));
%     % 太阳方位角
%     r_s(i,:) = acos((sin(delta(i)) - sin(alpha(i,:)).*sin(fai)) ./ (cos(alpha(i,:)).*cos(fai)));
%     % 地面直射强度
%     for j = 1:27
%         if alpha(i,j) > 0
%             I_DN(i,j) = I0(i) .* exp(-KL ./ sin(alpha(i,j)));
%         end
%     end
%     I_B = zeros(3,27);
%     % 计算不同倾斜角度下的辐射强度和总辐射能量
%     for k = 1:length(beta_range_rad)
%         I_B(i,:) = I_DN(i,:) .* abs(cos(alpha(i,:)).*cos(r_s(i,:)).*sin(beta_range_rad(k)).*cos(p) + cos(alpha(i,:)).*sin(p).*sin(beta_range_rad(k)).*sin(r_s(i,:)) + sin(alpha(i,:)).*cos(beta_range_rad(k)));
%         max_intensity(i, k) = max(I_B(i,:));
%         total_energy(i, k) = trapz(time, I_B(i,:)*3600);
%     end
% end
% 
% figure;
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
clc, clear, close all

% 输入数据
date = [14, 46, 74, 105, 135, 166, 196, 227, 258, 288, 319, 349];
KL = 0.5553; % 大气透过率
fai = deg2rad(30.58); % 当地纬度
I0 = [1405, 1394, 1378, 1353, 1334, 1316, 1308, 1315, 1330, 1350, 1372, 1392]; % 大气层外太阳辐射强度(W/m²)
time = 6:0.5:19; % 时间序列(h)
time = time';
omega = pi/12 * (time - 12); % 太阳时角(弧度)

% 光伏板的倾角从0到50度变化
beta_range = 0:1:50;
beta_range_rad = deg2rad(beta_range);

% 初始化存储变量
delta = zeros(12,1);
alpha = zeros(12,27);
r_s = zeros(12,27);
I_DN = zeros(12,27);

% 朝向角列表
azimuth_angles = [70, 75, 80];
total_energy = zeros(12, length(beta_range), length(azimuth_angles));

for a = 1:length(azimuth_angles)
    p = deg2rad(azimuth_angles(a));
    for i = 1:12
        n = date(i);
        % 第i个月的太阳赤纬角(弧度)
        delta(i) = deg2rad(23.45 * sind((360/365)*(n-81)));
        % 太阳高度角
        alpha(i,:) = asin(cos(delta(i))*cos(fai)*cos(omega) + sin(delta(i))*sin(fai));
        % 太阳方位角
        r_s(i,:) = acos((sin(delta(i)) - sin(alpha(i,:)).*sin(fai)) ./ (cos(alpha(i,:)).*cos(fai)));
        % 地面直射强度
        for j = 1:27
            if alpha(i,j) > 0
                I_DN(i,j) = I0(i) .* exp(-KL ./ sin(alpha(i,j)));
            end
        end
        I_B = zeros(3,27);
        % 计算不同倾斜角度下的辐射强度和总辐射能量
        for k = 1:length(beta_range_rad)
            I_B(i,:) = I_DN(i,:) .* abs(cos(alpha(i,:)).*cos(r_s(i,:)).*sin(beta_range_rad(k)).*cos(p) + cos(alpha(i,:)).*sin(p).*sin(beta_range_rad(k)).*sin(r_s(i,:)) + sin(alpha(i,:)).*cos(beta_range_rad(k)));
            total_energy(i, k, a) = trapz(time, I_B(i,:)*3600);
        end
    end
end

% 绘制结果
figure;
for a = 1:length(azimuth_angles)
    subplot(length(azimuth_angles), 1, a);
    for k = 1:12
        plot(beta_range, total_energy(k,:,a), 'LineWidth', 2);
        hold on;
    end
    title(sprintf('朝向角 = %d°', azimuth_angles(a)), 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('倾角 (度)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('太阳直射辐射总能量 (J)', 'FontSize', 12, 'FontWeight', 'bold');
    legend('1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月', 'Location', 'Best');
    grid on;
    hold off;
end

sgtitle('不同朝向角下的倾角与总能量变化', 'FontSize', 16, 'FontWeight', 'bold');
