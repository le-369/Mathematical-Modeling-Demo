% 定义ODE方程
function dYdt = car_model(t, Y, V, delta_f, lr, lf)
    X = Y(1);
    Y_pos = Y(2);
    psi = Y(3);
    
    beta = atan((lr / (lf + lr)) * tan(delta_f));
    dXdt = V * cos(beta + psi);
    dYdt_pos = V * sin(beta + psi);
    dpsidt = (V * cos(beta) * tan(delta_f)) / (lf + lr);
    
    dYdt = [dXdt; dYdt_pos; dpsidt];
end