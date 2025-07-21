% %% 第二问，使用网格算法来进行求解
% %% 通过每个月的15号来近似该月的情况，我们的目标是使12个月的（只对应12个数据）
% %% 辐射总能量达到最大，通过之前对该地的灵敏度检验，已经确定了该地的最优朝向角
% %% 应该在135~225°之间，通过网格算法来确定个朝向角对应的最优倾角。
% clc,clear,close all
% 
% date = [14,46,74,105,135,166,196,227,258,288,319,349];
% % 大气透过率
% KL = 0.5553;
% % 当地维度
% fai = deg2rad(30.58);
% % 大气层外太阳辐射强度(W/m²)
% I0 = [1405,1394,1378,1353,1334,1316,1308,1315,1330,1350,1372,1392];
% % 时间序列(h)
% time = 6:0.5:19;
% time = time';
% % 太阳时角(弧度)
% omega = pi/12*(time-12);
% 
% % 光伏板的朝向角从60~75来进行变化
% azimuth = deg2rad(50:1:75);
% % 光伏板的倾角设置为0~50度来进行变化
% beta_range_rad = deg2rad(0:1:50);
% 
% delta = zeros(12,1); % 赤纬角
% alpha = zeros(12,27); % 太阳高度角
% r_s = zeros(12,27); % 太阳方位角
% I_DN = zeros(12,27); % 地面直射强度
% total_E = zeros(length(beta_range_rad),1); % 每年总能量
% compare_E = 0; % 对比能量
% 
% for a = 1:length(azimuth)
%     total_E(:) = 0; % 每次计算新的朝向角时重置总能量
%     % 计算在同一个朝向角下，不同的倾斜角度每年总能量的最大值
%     for k = 1:length(beta_range_rad)
%         for i = 1:12
%             n = date(i);
%             % 第i个月的太阳赤纬角(弧度)
%             delta(i) = deg2rad(23.45 * sind((360/365)*(n-81)));
%             % 太阳高度角
%             alpha(i,:) = asin(cos(delta(i))*cos(fai)*cos(omega) + sin(delta(i))*sin(fai));
%             % 太阳方位角
%             r_s(i,:) = acos((sin(delta(i)) - sin(alpha(i,:)).*sin(fai)) ./ (cos(alpha(i,:)).*cos(fai)));
%             % 地面直射强度
%             for j = 1:27
%                 if alpha(i,j) > 0
%                     I_DN(i,j) = I0(i) .* exp(-KL ./ sin(alpha(i,j)));
%                 end
%             end
% 
%             I_B = zeros(1,27);
% 
%             % 计算一天直射太阳板的强度(考虑到了余弦损失)
%             I_B(i,:) = I_DN(i,:) .* abs(cos(alpha(i,:)).*cos(r_s(i,:)).*sin(beta_range_rad(k)).*cos(azimuth(a)) + cos(alpha(i,:)).*sin(azimuth(a)).*sin(beta_range_rad(k)).*sin(r_s(i,:)) + sin(alpha(i,:)).*cos(beta_range_rad(k)));
%             % 这里求出的E是在一个倾角下一天的值，而我们要累积12天的值用来比较
%             E = trapz(time,I_B(i,:)*3600);
%             % 我们想找出在这个倾角下的每个月份的最大的能量，然后再将这个最大的能量累加起来
%             total_E(k) = E + total_E(k);
%         end
%     end
%     [max_E, max_index] = max(total_E); % 找到最大能量及对应的倾角
%     if compare_E < max_E
%         compare_E = max_E;
%         best_beta = beta_range_rad(max_index);
%         best_Z = azimuth(a);
%     end
% end
% 
% fprintf('最优固定倾角为：%d°\n',rad2deg(best_beta));
% fprintf('最优固定朝向角为：%d°\n',rad2deg(best_Z));
% fprintf('日均最大总能量为：%d\n',compare_E/12);
%%
clc, clear, close all

date = [14,46,74,105,135,166,196,227,258,288,319,349]; % 每个月的15号
KL = 0.5553; % 大气透过率
% 当地纬度
latitude = 30 + 35/60;
fai = deg2rad(latitude);
I0 = [1405,1394,1378,1353,1334,1316,1308,1315,1330,1350,1372,1392]; % 大气层外太阳辐射强度(W/m²)
time = 6:0.5:19; % 时间序列(h)
time = time';
% 太阳时角(弧度)
omega =  deg2rad(15 * (time - 12));

azimuth = deg2rad(145:1:225); % 光伏板的朝向角从60~75度变化
beta_range_rad = deg2rad(0:1:50); % 光伏板的倾角从0~50度变化

delta = zeros(12,1); % 赤纬角
alpha = zeros(12,27); % 太阳高度角
r_s = zeros(12,27); % 太阳方位角
I_DN = zeros(12,27); % 地面直射强度
total_E = zeros(length(beta_range_rad), length(azimuth)); % 每年总能量

for a = 1:length(azimuth)
    for k = 1:length(beta_range_rad)
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

            for j = 1:27
                if alpha(i,j) > 0
                    I_DN(i,j) = I0(i) .* exp(-KL ./ sin(alpha(i,j))); % 地面直射强度
                end
            end

            % 计算直射太阳板的强度(考虑到了余弦损失)
            I_B = I_DN(i,:) .* abs(sin(alpha(i,:)) .* cos(beta_range_rad(k)) + cos(alpha(i,:)) .* sin(beta_range_rad(k)) .* cosd(rad2deg(r_s(i,:))-rad2deg(azimuth(a))));
            % 累积当天的能量值
            E = trapz(time,I_B*3600)/1000; 
            total_E(k,a) = total_E(k,a) + E; % 累加每个月的能量值
        end
    end
end

% 找到最大能量及对应的倾角和朝向角
[compare_E, index] = max(total_E(:));
[best_k, best_a] = ind2sub(size(total_E), index);
best_beta = beta_range_rad(best_k);
best_Z = azimuth(best_a);

fprintf('最优固定倾角为：%.2f°\n', rad2deg(best_beta));
fprintf('最优固定朝向角为：%.2f°\n', rad2deg(best_Z));
fprintf('日均最大总能量为：%.2f\n', compare_E/12);

% 绘制三维网格图
[Beta, Azimuth] = meshgrid(rad2deg(beta_range_rad), rad2deg(azimuth));
figure;
mesh(Beta, Azimuth, total_E'./12);
xlabel('倾角 (°)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('朝向角 (°)', 'FontSize', 12, 'FontWeight', 'bold');
zlabel('总能量 (KJ)', 'FontSize', 12, 'FontWeight', 'bold');
title('光伏板朝向与日均总能量的关系', 'FontSize', 14, 'FontWeight', 'bold');
