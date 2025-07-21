% %% 第一问
% clc,clear,close all
% %% 每个月15号
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
%  zc = 0; % 光伏板的方位角（假设为正南方向）
% % 每月15日的太阳赤纬角
% delta = zeros(12,1);
% alpha = zeros(12,27);
% r_s = zeros(12,27);
% I_DN = zeros(12,27);
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
% 
%     % 光伏板的倾角
%     beta = [20,40,60];beta = deg2rad(beta);
% 
%     I_B = zeros(3,27);
%     % 不同倾斜角度下的辐射强度和总辐射能量
%     for k = 1:length(beta)
%         % 直射太阳板的强度(考虑到了余弦损失)
%         % I_B(k,:) = -I_DN(i,:) .* sin(alpha(i,:)+beta(k)) .* cos(abs( r_s(i,:)));
%         I_B(k,:) = I_DN(i,:) .* abs(sin(alpha(i,:)) .* cos(beta(k)) + ...
%              cos(alpha(i,:)) .* sin(beta(k)).*cos(zc) .* cos(r_s(i,:))+cos(alpha(i,:)).*sin(zc).*sin(beta(k)).*sin(r_s(i,:)));
% 
%         % alpha_s = alpha(i,:);    % 太阳高度角
%         % gamma_s = r_s(i,:);    % 太阳方位角
%         % beta_B = beta(k);     % 光伏板的倾角
%         % gamma_B = 0;     % 光伏板的方位角（假设为正南方向）
%         % 
%         % for j=1:27
%         %     OA=[-cos(alpha_s(j)).*cos(gamma_s(j)),-cos(alpha_s(j)).*sin(gamma_s(j)),-sin(alpha_s(j))];
%         %     OB=[sin(beta_B)*cos(0),sin(beta_B)*sin(0),cos(beta_B)];
%         %     sigma(j) =dot(OA,OB)/(norm(OA)*norm(OB));
%         % end
%         % 
%         % sigma=real(sigma);
%         % I_B(k,:) = I_DN(i,:).*abs(sigma);
% 
%         E= trapz(time,I_B(k,:)*3.6);
%         fprintf('第%d个月光伏板倾角 %d° 时的最大太阳直射强度:%.2f W/m²\n',i,rad2deg(beta(k)),max(I_B(k,:)));
%         fprintf('第%d个月光伏板倾角 %d° 时的太阳直射辐射总能量：%.2f KJ\n\n', i,rad2deg(beta(k)), E);
%     end
% end
% 
% %% 对大气透过率进行灵敏度检验，观察5月15日的太阳直射辐射总能量，与最大太阳直射强度
% 
% clc,clear,close all
%  zc = 0; 
% date = [14,46,74,105,135,166,196,227,258,288,319,349];
% % 大气透过率
% KL = 0:0.1:1;
% % 当地维度
% fai = deg2rad(30.58);
% % 大气层外太阳辐射强度(W/m²)
% I0 = [1405,1394,1378,1353,1334,1316,1308,1315,1330,1350,1372,1392];
% % 时间序列(h)
% time = 6:0.5:19;
% % 太阳时角(弧度)
% omega = pi/12*(time-12);
% 
% % 每月15日的太阳赤纬角
% delta = zeros(1,1);
% alpha = zeros(1,27);
% r_s = zeros(1,27);
% I_DN = zeros(1,27);
% for m=1:11
% i = 5;
%     n = date(i);
%     % 第i个月的太阳赤纬角(弧度)
%     delta = deg2rad(23.45 * sind((360/365)*(n-81)));
%     % 太阳高度角
%     alpha = asin(cos(delta)*cos(fai)*cos(omega) + sin(delta)*sin(fai));
%     % 太阳方位角
%     r_s = acos((sin(delta) - sin(alpha).*sin(fai)) ./ (cos(alpha).*cos(fai)));
%     % 地面直射强度
%     for j = 1:27
%         if alpha(j) > 0
%             I_DN(j) = I0(i) .* exp(-KL(m) ./ sin(alpha(j)));
%         end
%     end
% 
% 
%     % 光伏板的倾角
%     beta = 40;beta = deg2rad(beta);
%     I_B = zeros(3,27);
%     % 不同倾斜角度下的辐射强度和总辐射能量
%         % 直射太阳板的强度(考虑到了余弦损失)
% 
%          I_B = I_DN .* abs(sin(alpha) .* cos(beta) + ...
%              cos(alpha) .* sin(beta).*cos(zc) .* cos(r_s)+cos(alpha).*sin(zc).*sin(beta).*sin(r_s));
%         E(m)= trapz(time,I_B.*3600);
%         figure(1);
%         plot(KL(m),max(I_B),'o');
%         hold on;
% end
%     figure(2);
%     plot(KL,E,'o');
% 
% 
% %% 对朝向角进行灵敏度分析，光伏板的方位角（假设为正南方向）
% 
% clc,clear,close all
%  zc = 0:1:360; 
%  zc=deg2rad(zc);
% date = [14,46,74,105,135,166,196,227,258,288,319,349];
% % 大气透过率
% KL=0.5;
% % 当地维度
% fai = deg2rad(30.58);
% % 大气层外太阳辐射强度(W/m²)
% I0 = [1405,1394,1378,1353,1334,1316,1308,1315,1330,1350,1372,1392];
% % 时间序列(h)
% time = 6:0.5:19;
% % 太阳时角(弧度)
% omega = pi/12*(time-12);
% 
% % 每月15日的太阳赤纬角
% delta = zeros(1,1);
% alpha = zeros(1,27);
% r_s = zeros(1,27);
% I_DN = zeros(1,27);
% for m=1:length(zc)
%     i = 5;
%     n = date(i);
%     % 第i个月的太阳赤纬角(弧度)
%     delta = deg2rad(23.45 * sind((360/365)*(n-81)));
%     % 太阳高度角
%     alpha = asin(cos(delta)*cos(fai)*cos(omega) + sin(delta)*sin(fai));
%     % 太阳方位角
%     r_s = acos((sin(delta) - sin(alpha).*sin(fai)) ./ (cos(alpha).*cos(fai)));
%     % 地面直射强度
%     for j = 1:27
%         if alpha(j) > 0
%             I_DN(j) = I0(i) .* exp(-KL ./ sin(alpha(j)));
%         end
%     end
%     % 光伏板的倾角
%     beta = 60;beta = deg2rad(beta);
%     % 不同倾斜角度下的辐射强度和总辐射能量
%         % 直射太阳板的强度(考虑到了余弦损失)
%          I_B = I_DN .* abs(sin(alpha) .* cos(beta) + ...
%               cos(alpha) .* sin(beta).*cos(zc(m)) .* cos(r_s)+cos(alpha).*sin(zc(m)).*sin(beta).*sin(r_s));
%         % alpha_s = alpha;    % 太阳高度角
%         % gamma_s = r_s;    % 太阳方位角
%         % beta_B = beta;     % 光伏板的倾角
%         % gamma_B = zc(m);     % 光伏板的方位角（假设为正南方向）
%         % for j=1:27
%         %     OA=[-cos(alpha_s(j)).*cos(gamma_s(j)),-cos(alpha_s(j)).*sin(gamma_s(j)),-sin(alpha_s(j))];
%         %     OB=[sin(beta_B)*cos(zc(m)),sin(beta_B)*sin(zc(m)),cos(beta_B)];
%         %     sigma(j) =dot(OA,OB)/(norm(OA)*norm(OB));
%         % end
%         % sigma=real(sigma);
%         % I_B = I_DN.*abs(sigma);
%         E(m)= trapz(time,I_B.*3600);
%         figure(1);
%         plot(rad2deg(zc(m)),E(m),'o');
%         hold on;
% end
% 
% 
% 



%% 第2问,假设一个月的太阳辐射与每月十五号一样；且由前面问题可知当板朝向正南，
% clear,clc;
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
%  zc = 0; % 光伏板的方位角（假设为正南方向）
% % 每月15日的太阳赤纬角
% delta = zeros(12,1);
% alpha = zeros(12,27);
% r_s = zeros(12,27);
% I_DN = zeros(12,27);
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
% 
%     % 光伏板的倾角
%     beta =0:1:90;beta = deg2rad(beta);
%     % 不同倾斜角度下的辐射强度和总辐射能量
%     for k = 1:length(beta)
%         % 直射太阳板的强度(考虑到了余弦损失)
%         I_B(k,:) = I_DN(i,:) .* abs(sin(alpha(i,:)) .* cos(beta(k)) + ...
%              cos(alpha(i,:)) .* sin(beta(k)).*cos(zc) .* cos(r_s(i,:))+cos(alpha(i,:)).*sin(zc).*sin(beta(k)).*sin(r_s(i,:)));
%         E(i,k) = trapz(time,I_B(k,:)*3.6);
%     end
% 
% end
% e1=sum(E,1); %总的太阳辐射能量
% plot(rad2deg(beta),e1);
% 
% [~,maxinder]=max(e1);
% disp(rad2deg(beta(maxinder)));%最大日均太阳辐射能量角度
% disp(e1(maxinder)/12,"最大日均太阳辐射能量");


%% 第三问，NSGA II
clc, clear;

% 优化参数
fitnessfcn = @fun;
nvars = 2;
lb = [0, 0]; % 下界
ub = [pi/2, 2*pi]; % 上界
options = optimoptions('gamultiobj', 'PopulationSize', 100, 'MaxGenerations', 200);
[x, fval] = gamultiobj(fitnessfcn, nvars, [], [], [], [], lb, ub, options);

% 结果提取
figure(1)
y1 = -fval(:,1);
y2 = -fval(:,2);
plot(y1, y2, 'o');
xlabel('储电效率/时');
ylabel('储电量/kJ');
title('储电效率与储电量的关系');

figure(2)
% x(1)倾角，x(2)方位角
x1 = rad2deg(x(:,1));
x2 = rad2deg(x(:,2));
plot(x1, x2, 'o');
xlabel('倾角/°');
ylabel('方位角/°');
title('优化后的倾角与方位角');






