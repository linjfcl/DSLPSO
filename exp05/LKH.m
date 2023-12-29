function [tspLen, route] = LKH(points)

n = size(points,1);
D = zeros(n,n);
for i = 1:n
    for j = 1:n
        if i ~= j
            D(i,j) = sqrt(sum((points(i,:) - points(j,:)).^2));
        else
            D(i,j) = 0;
        end
    end
end
D = floor(D);

file = 'TSP\';
tspFileId = fopen([file 'temp.tsp'], 'w');

fprintf(tspFileId, 'NAME : temp\n');
fprintf(tspFileId, 'COMMENT : temp file\n');
fprintf(tspFileId, 'TYPE : TSP\n');
fprintf(tspFileId, 'DIMENSION : %d\n', n);
fprintf(tspFileId, 'EDGE_WEIGHT_TYPE : EXPLICIT\n');
fprintf(tspFileId, 'EDGE_WEIGHT_FORMAT : FULL_MATRIX\n');
fprintf(tspFileId, 'EDGE_WEIGHT_SECTION\n');
for i = 1:size(D, 1)
    for j = 1:size(D, 2)
        fprintf(tspFileId, '%d ', D(i, j));
    end
    fprintf(tspFileId, '\n');
end
fprintf(tspFileId, 'EOF');
fclose(tspFileId);

lkh_cmd = ['echo 0|' file 'LKH' ' ' file 'temp.par'];
[~,~] = system(lkh_cmd);

ansFileId = fopen([file 'temp.txt'], 'r');

for i = 1:6
    fgetl(ansFileId);
end

route = fscanf(ansFileId, '%d')';
fclose(ansFileId);

route(length(route)) = 1;
xx = points(route(2:length(route)), :) - points(route(1:length(route)-1), :);
tspLen = sum(sqrt(sum(xx.^2, 2)));

end

