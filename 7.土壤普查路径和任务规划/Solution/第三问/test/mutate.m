function mutated = mutate(chromosome)
    % 交换变异操作
    n = length(chromosome);
    
    % 随机选择两个位置
    pt1 = randi(n);
    pt2 = randi(n);
    
    % 交换这两个位置的基因
    temp = chromosome(pt1);
    chromosome(pt1) = chromosome(pt2);
    chromosome(pt2) = temp;
    
    mutated = chromosome;
end
