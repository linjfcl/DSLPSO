function SLPSO(Para, Data)
% 淬火策略的PSO
    
    tic;
    % 1. 初始化
    
    % 1.1 初始化运行参数
    Para = ParaInitial(Para);                   % 根据输入的参数生成配置信息
    
    % 1.4 生成输出的数据结构体
    record   = zeros(1, Para.totaltime);       % 记录最优结果参数
    record0  = zeros(1, Para.totaltime);       % 记录传输消耗的能量
    initFes  = zeros(1, Para.totaltime);
    
    FbestRec = zeros(Para.totaltime, Para.maxEvaluations);    % 记录每一轮的运行过程

    RA = zeros(Para.totaltime, Para.maxEvaluations); % 记录R值的变化

    quench = 2;  % 淬火次数

    for run = 1 : Para.totaltime

        % 初始化
        % 初始化传播半径
        Rmax = Para.lu(2,:) - Para.lu(1,:);    % 最大传播半径

        Para.evaluations = 0;
        C = 1;

        % 记录各种操作成果的情况
        s_ins = 0;   % 统计由 新增       算子产生优化的次数
        s_rep = 0;   % 统计由 替换       算子产生优化的次数
        s_del = 0;   % 统计由 删除       算子产生优化的次数
        f_ins = 0;   % 统计由 新增       算子产生优化的值
        f_rep = 0;   % 统计由 替换       算子产生优化的值
        f_del = 0;   % 统计由 删除       算子产生优化的值

        rr = 0; % reomve操作连续多少次失败
        rc = 1; % 什么时候执行remove操作
        
        % 初始化种群
        while C~=0
            % 随机一个初始的种群
            UAVPosition0 = repmat(Para.lu(1, :), Para.NSP, 1) + rand(Para.NSP, length(Para.lu)) .* (repmat(Para.lu(2, :) - Para.lu(1, :), Para.NSP, 1));
    
            % 测试当前的随机的结果是否满足约束条件
            [initVal, C] = Fitness(UAVPosition0, Data.IoTPosition, Para, Data); % 计算路径的可行，使用原型算法
            Para.evaluations = Para.evaluations + 1;
            initFes(run) = Para.evaluations;
            if(initFes(run) > Para.maxEvaluations)
                disp("初始化失败！！")
                break;
            end
        end
        if C ~= 0
            continue;
        end

        Fbest = initVal;  % 初值设置
        f_inv = Fbest;    % 初始的适应度

        UAVPosition = [UAVPosition0, zeros(Para.NSP, 2)];  % 增加 self-guidance

        G = 0;
        % 直到终止条件前，循环
        while(Para.evaluations < Para.maxEvaluations)   % 算法终止条件
            NS = size(UAVPosition, 1);           % NS表示当前策略下无人机的个数；
            n = 3;                          % n在本文中为3。
            Fbest = Fitness(UAVPosition(:, 1:3), Data.IoTPosition, Para, Data);

%             R = Rmax * (Para.maxEvaluations - Para.evaluations) / Para.maxEvaluations;
%             R = Rmax * mod((Para.maxEvaluations - Para.evaluations), (Para.maxEvaluations/quench)) / (Para.maxEvaluations/quench);
            cUnit = Para.maxEvaluations/quench; % 一次淬火有几代
            R = (Rmax/2^(floor(Para.evaluations/cUnit))) * mod((Para.maxEvaluations - Para.evaluations), cUnit) / cUnit;

            % -----------Remove操作-----------
            if(rc > 0)
                rf = 0;   % 是否存在优化
                for i = NS:-1:1
                    offpop = UAVPosition;
                    offpop(i, :) = [];
                    fval = Fitness(offpop(:, 1:3), Data.IoTPosition, Para, Data);
                    if(Fbest >= fval) % 和全局最优比较
                        rf = 1;
                        rr = 0;
                        if(Para.print)
                            fprintf("★")
                        end
                        f_del = f_del + (Fbest - fval);
                        s_del = s_del + 1;
                        Fbest = fval;
                        UAVPosition = offpop;
                        FbestRec(run, Para.evaluations) = Fbest;
                        RA(run, Para.evaluations) = R(1);
                    end
                    Para.evaluations = Para.evaluations + 1;
                end
                if(rf == 0) % 如果不存在优化
                    rr = rr + 1;
                    rc = rc - rr;
                else % 如果存在优化
                    rc = rc + 1;
                end
            else
                rc = rc + 1;
            end

            % -----------Replace操作-----------
            ff = 0; % replace是否有优化
            offpop = UAVPosition;
            for i = 1 : size(UAVPosition, 1)
                individual = offpop(i, :);
                if(offpop(i, 4) == 0)
                    offpop(i, 1:3) = offpop(i, 1:3) + (rand(1,n)*2-1).*R;     % 如果没有惯性，就随机游走
                else
                    offpop(i, 1:3) = offpop(i, 1:3) + [offpop(i, 4:5), 0] .* rand(1,3);  % 如果有惯性，顺着惯性走
                end
                fval = Fitness(offpop(:, 1:3), Data.IoTPosition, Para, Data);

                if(Fbest > fval) % 比全局最优还好
                    % 计算惯性向量
                    A = offpop(i, 1:2) - individual(1:2);
                    % 将这个向量长度修改为R
                    B = sqrt(sum(A.*A)) / sqrt(sum(R.*R));
                    offpop(i, 4:5) = A / B;

                    ff = 1;
                    f_rep = f_rep + (Fbest - fval);
                    s_rep = s_rep + 1;
                    Fbest = fval;
                    FbestRec(run, Para.evaluations) = Fbest;
                    RA(run, Para.evaluations) = R(1);
                else
                    offpop(i, :) = individual;
                    offpop(i, 4:5) = 0;
                end
                Para.evaluations = Para.evaluations + 1;
            end
            UAVPosition = offpop;  % 同步惯性向量

            if(Para.print)
                if(ff == 1)  % 如果replace存在更好的结果
                    fprintf("■")
                else % 如果不存在更好的结果
                    fprintf("□")
                end
            end
            RA(run, Para.evaluations) = R(1);

            G = G + 1;
        end

        Fbest = Fitness(UAVPosition(:, 1:3),Data.IoTPosition,Para,Data);
        record(run) = Fbest;
        record0(run) = Fitness(UAVPosition(:, 1:3),Data.IoTPosition,Para,Data);
        if(Para.print)
            fprintf("");
            fprintf("子种群优化：%d  replace优化：%d  delete优化：%d\n", s_ins, s_rep, s_del);
            fprintf("子种群优化：%d  replace优化：%d  delete优化：%d\n", f_ins, f_rep, f_del);
            fprintf("计算最优值为：%f - %f - %f- %f = %f\n", f_inv, f_ins, f_rep, f_del, f_inv-f_ins-f_rep-f_del);
        end
        fprintf("%-15s算法，第%d次运行，最优值为%f，总共迭代%d代\n", Para.name, run, Fbest, G);
        
    end
    time = toc;
    % 保存运行的数据
    if Para.save
        save(Para.name);
    end
    
end
    