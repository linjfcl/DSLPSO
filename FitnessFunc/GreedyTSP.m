function [tspLen, bestRoute] = GreedyTSP(points)

n = size(points,1);
D = zeros(n,n);
for i = 1:n
    for j = 1:n
        if i ~= j
            D(i,j) = sqrt(sum((points(i,:) - points(j,:)).^2));
        else
            D(i,j) = Inf;
        end
    end
end

tspLen = Inf;

for m = 1:n

    route = zeros(1, n+1);
    route(1) = m;
    len = 0;

    for j = 1:n-1 
        [~, DI] = sort(D(route(j), :));
        for index = DI
            if(sum(route == index) == 0)
                route(j+1) = index;
                len = len + D(route(j), route(j+1));
                break;
            end
        end
    end

    route(n+1) = m;
    len = len + D(route(n), route(n+1));

    if(len < tspLen)
        tspLen = len;
        bestRoute = route;
    end

end