     %梯度下降法来确定使光伏板全年接收到的太阳直射辐射总能量最大的最佳倾角
    clc,clear, close all
    
    %% 每个月15号
    date = [14,46,74,105,135,166,196,227,258,288,319,349];
    
    % 大气透过率
    KL = 0.5553;
    
    % 当地维度
    fai = deg2rad(30.58);
    
    % 大气层外太阳辐射强度(W/m²)
    I0 = [1405,1394,1378,1353,1334,1316,1308,1315,1330,1350,1372,1392];
    
    % 时间序列(h)
    time = 6:0.5:19;
    time = time';
    
    % 太阳时角(弧度)
    omega = pi/12*(time-12);
    
    % 每月15日的太阳赤纬角
    delta = zeros(12,1);
    alpha = zeros(12,27);
    r_s = zeros(12,27);
    I_DN = zeros(12,27);
    
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
    end
    
    % 定义目标函数
    objFun = @(beta) -totalEnergy(beta, delta, alpha, r_s, I_DN, time);
    
    % 初始倾角
    beta_init = deg2rad(40);
    
    % 学习率
    learning_rate = 0.001;
    
    % 最大迭代次数
    max_iters = 1000;
    
    % 梯度下降
    beta_opt = gradientDescent(objFun, beta_init, learning_rate, max_iters);
    
    % 输出最佳倾角
    fprintf('最佳光伏板倾角为: %.2f度\n', rad2deg(beta_opt));

function E_total = totalEnergy(beta, delta, alpha, r_s, I_DN, time)
    % 不同倾斜角度下的辐射强度和总辐射能量
    I_B = zeros(size(I_DN));
    for i = 1:size(I_DN,1)
        I_B(i,:) = I_DN(i,:) .* abs(sin(alpha(i,:)) .* cos(beta) + cos(alpha(i,:)) .* sin(beta) .* cos(r_s(i,:)));
        E = trapz(time, I_B(i,:).*3600); % 积分求总能量
        E_total(i) = E;
    end
    E_total = sum(E_total);
end

function beta_opt = gradientDescent(objFun, beta_init, learning_rate, max_iters)
    beta = beta_init;
    for iter = 1:max_iters
        grad = finiteDiffGradient(objFun, beta);
        beta = beta + learning_rate * grad;
        beta = projectToInterval(beta); % 确保beta在0到90度之间
    end
    beta_opt = beta;
end

function grad = finiteDiffGradient(objFun, beta)
    h = 1e-5; % 步长
    grad = (objFun(beta+h) - objFun(beta-h)) / (2*h);
end

function beta = projectToInterval(beta)
    % 确保beta在0到90度之间
    beta = min(max(beta, 0), deg2rad(90));
end