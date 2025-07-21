function d = haversine(lon1, lat1, lon2, lat2)
    R = 6371; % 地球半径，单位：km
    dlon = deg2rad(lon2 - lon1);    % 经度
    dlat = deg2rad(lat2 - lat1);    % 纬度
    a = sin(dlat/2).^2 + cos(deg2rad(lat1)) .* cos(deg2rad(lat2)) .* sin(dlon/2).^2;
    c = 2 .* atan2(sqrt(a), sqrt(1-a));
    d = R * c;
end
