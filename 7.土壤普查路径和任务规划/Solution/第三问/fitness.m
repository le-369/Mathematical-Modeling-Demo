function [t,s,day,dt] = f(S0,da,D)
Sum=0;
day=1;
dt{day}=[];
t1=da(S0(1),4)/60;
for i=1:length(S0)-1
    Sum=D(S0(i),S0(i+1))+Sum;
    t1=D(S0(i),S0(i+1))/20+da(S0(i+1),4)/60+t1;
    if t1 > 8.5
        Sum=0;
        day=day+1;
        dt{day}=[S0(i)];
        t1=da(S0(i+1),4)/60;
        continue;
    end
    t(day)=t1;
    s(day)=Sum;
    dt{day}=[dt{day},S0(i)];
end
end