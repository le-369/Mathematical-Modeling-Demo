function y = fun(x, latitude)
    % x(1)倾角，x(2)方位角
    % y(1)储电效率，y(2)储电量

    date = [14, 46, 74, 105, 135, 166, 196, 227, 258, 288, 319, 349];
    % 大气透过率
    KL = 0.5553;
    % 当地维度
    fai = deg2rad(latitude);
    % 大气层外太阳辐射强度(W/m²)
    I0 = [1405, 1394, 1378, 1353, 1334, 1316, 1308, 1315, 1330, 1350, 1372, 1392];
    % 时间序列(h)
    time = 6:0.5:19;
    time = time';
    % 太阳时角(弧度)
    omega =  deg2rad(15 * (time - 12));
    zc = x(2); % 光伏板的方位角（假设为正南方向）
    % 每月15日的太阳赤纬角
    delta = zeros(12, 1);
    alpha = zeros(12, 27);
    r_s = zeros(12, 27);
    I_DN = zeros(12, 27);
    t = 0; % 重置 t
    
    for i = 1:12
        n = date(i);
        % 第i个月的太阳赤纬角(弧度)
        delta(i) = deg2rad(23.45 * sind((360 / 365) * (n - 81)));
        % 太阳高度角
        alpha(i, :) = asin(cos(delta(i)) * cos(fai) * cos(omega) + sin(delta(i)) * sin(fai));
        
        % 太阳方位角
        phi_s_temp = acos((sin(delta(i)) - sin(alpha(i, :)) * sin(fai)) ./ (cos(alpha(i, :)) * cos(fai)));
        phi_s = phi_s_temp;
        phi_s(omega >= 0) = 2 * pi - phi_s_temp(omega >= 0);
        r_s(i, :) = phi_s;

        % 地面直射强度
        for j = 1:27
            if alpha(i, j) > 0
                I_DN(i, j) = I0(i) .* exp(-KL ./ sin(alpha(i, j)));
            end
        end
        
        % 光伏板的倾角
        beta = x(1);
        % 直射太阳板的强度(考虑到了余弦损失)
        I_B = I_DN(i,:) .* abs(sin(alpha(i,:)) .* cos(beta) + cos(alpha(i,:)) .* sin(beta) .* cosd(rad2deg(r_s(i,:))-rad2deg(zc)));
        E(i) = trapz(time, I_B * 3.6); % 日辐射总量
        for j = 1:27
            if I_B(j) > 150 && j <= 13
                t = t + 0.5;
            elseif I_B(j) > 100 && j > 13
                t = t + 0.5;
            end
        end
    end
    y(2) = -sum(E) / 12; % 储电量（取负值用于最小化问题）
    y(1) = -t/12; % 储电效率（取负值用于最小化问题）
end