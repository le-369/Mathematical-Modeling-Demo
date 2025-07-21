

%%函数
function   bk(c,current_city, visited, current_length, count)
%递推函数
%   此处显示详细说明
        global dist;
        global min_length;
        global min_c;
        %退出条件
      if count == 8
          if min_length>current_length
                min_length = min(min_length, current_length);
                min_c =c;
          end
          return;
      end
        
        for next_city = 1:8
            if  visited(next_city)
                visited(next_city) = false;
                bk([c,next_city],next_city, visited, current_length + dist(current_city, next_city), count + 1);
                visited(next_city) = true;
            end
        end
end
