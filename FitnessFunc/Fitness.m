function [F,C] = Fitness(UAVPosition,IoTPosition,Para,Data)


Distance = pdist2(UAVPosition, IoTPosition);
[~,a]    = min(Distance,[],1);

for i = 1:size(UAVPosition,1) 
    index = find(a == i);  
    if size(index,2)>Para.K
        [~,temp] = sort(Distance(i,index));
        a(index(temp(Para.K+1:end))) = 0;
    end
end

F = inf;
Th = zeros(size(UAVPosition,1),1);
if sum(a==0)==0 
    for i = 1:Para.NIoT
        h = Para.rho/Distance(a(i),i)^2; 
        r = Para.B*log2(1+Para.p*h/Para.sigma);
        Th(a(i)) = max(Data.D(i)/r,Th(a(i))); 
    end

    Eiot  =  sum(Para.p*Data.D./r); 
    Euav  =  Para.ph*sum(Th);
    F = 10000*Eiot+Euav;  
end
C = sum(a==0);
end
