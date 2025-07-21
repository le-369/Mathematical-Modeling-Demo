% 定义多目标函数
function F = multi_objective_function(x, w, safe_distance, lr, lf, V)
    d = x(1);       % 前向距离
    delta_f = x(2); % 转弯角度
    
    % 碰撞检查
    if collision_check(d, delta_f, w, safe_distance, lr, lf, V)
        F(1) = 1e6; % 碰撞情况下的惩罚值
        F(2) = 1e6; % 碰撞情况下的惩罚值
    else
        F(1) = -delta_f; % 最大化转弯角度
        F(2) = delta_f;  % 最小化转弯角度
    end
end