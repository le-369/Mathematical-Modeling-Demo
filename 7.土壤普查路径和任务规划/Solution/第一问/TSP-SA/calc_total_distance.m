function total_dist = calc_total_distance(route, distMatrix)
    n = length(route);
    total_dist = 0;
    for i = 1:(n-1)
        total_dist = total_dist + distMatrix(route(i), route(i+1));
    end
end
