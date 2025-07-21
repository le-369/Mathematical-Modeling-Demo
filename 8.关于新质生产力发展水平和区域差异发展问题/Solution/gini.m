function f= gini(data)
    % 确保输入数据是列向量
    if isrow(data)
        data = data';
    end

    % 排序数据
    sorted_data = sort(data);
    
    % 计算累计收入
    n = length(sorted_data);
    cumulative_income = cumsum(sorted_data);
    
    % 计算洛伦茨曲线
    cumulative_income_share = cumulative_income / cumulative_income(end);
    cumulative_population_share = (1:n) / n;
    
    % 计算基尼系数
    lorenz_curve_area = trapz(cumulative_population_share, cumulative_income_share);
    equal_distribution_area = 0.5; % 完全平等线下的面积
    f = (equal_distribution_area - lorenz_curve_area) / equal_distribution_area;
end