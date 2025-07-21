% 最大转弯角度目标函数
function cost = collision_check_max(x, w, safe_distance, lr, lf, V)
    d = x(1);       % 前向距离
    delta_f = x(2); % 角度
    
    % 定义滑移角 beta
    beta = atan(lr * tan(delta_f) / (lf + lr));
    L = lr + lf;

    % 初始条件
    X0 = 0;
    Y0 = d;
    psi0 = pi/2;

    % 时间范围
    t_span = [0,100]; % 每隔0.1秒

    % 定义微分方程
    odefun = @(t, y) [
        V * cos(beta + y(3));
        V * sin(beta + y(3));
        V * cos(beta) * tan(delta_f) / L
    ];

    % 初始条件向量
    y0 = [X0; Y0; psi0];

    % 数值求解微分方程
    [t, y] = ode45(odefun, t_span, y0);

    % 提取解
    X_vals = y(:, 1);
    Y_vals = y(:, 2);
    psi_vals = y(:, 3);

    % 计算四个轮子的坐标
    wheel_offsets = [
        lf, -w/2; % 前右轮 (FR)
        -lr, w/2; % 后左轮 (RL)
    ];

    FR_x = zeros(size(t));
    FR_y = zeros(size(t));
    RL_x = zeros(size(t));
    RL_y = zeros(size(t));

    for i = 1:length(t)
        % 旋转矩阵
        R_matrix = [cos(psi_vals(i)), -sin(psi_vals(i)); sin(psi_vals(i)), cos(psi_vals(i))];
        
        % 计算四个轮子的偏移量
        FR_offset = R_matrix * wheel_offsets(1, :)';
        RL_offset = R_matrix * wheel_offsets(2, :)';
        
        % 计算全局坐标
        FR_x(i) = X_vals(i) + FR_offset(1);
        FR_y(i) = Y_vals(i) + FR_offset(2);
        RL_x(i) = X_vals(i) + RL_offset(1);
        RL_y(i) = Y_vals(i) + RL_offset(2);
    end

     % 找出FR_y最大的那个点的索引
    [~, max_y_index] = max(FR_y);
    % 取FR_y最大的那个点的FR_x和FR_y
    max_FR_y = FR_y(max_y_index);
    
    [~, RL_y_index] = max(RL_y);

    % 碰撞检查
    collision = false;

    % 左侧车辆
    for i = 1:RL_y_index
        if RL_x(i) < -(w/2 + 0.4)
            if RL_y(i) < 2 + safe_distance
                collision = true;
            end
        end
    end

    % if any(RL_y < L/2 + safe_distance & RL_x < -(w/2 + 0.4) & RL_x > -(w/2 + 0.4 + 2))
    %     collision = true;
    % end

    % 上方车辆
    if max_FR_y >= 0.55 + 5.5 + 5.3/2
        collision = true;
    end

    % 如果发生碰撞，返回一个大的惩罚值
    if collision
        cost = 1e6; % 碰撞情况下的惩罚值
    else
        cost = -delta_f;
    end
end
