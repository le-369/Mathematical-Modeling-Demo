function offspring = crossover_single_chromosome(chromosome)
    % 获取染色体长度
    n = length(chromosome);
    
    % 随机选择两个交叉点
    pt1 = randi([1, n-1]);
    pt2 = randi([pt1+1, n]);
    
    % 提取两个片段
    segment1 = chromosome(pt1:pt2);
    segment2 = chromosome([1:pt1-1, pt2+1:n]);
    
    % 交叉片段
    offspring = [segment2(1:pt1-1), segment1, segment2(pt1:end)];
end
