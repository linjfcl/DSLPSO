function SLPSO(Para, Data)

    tic;
    
    Para = ParaInitial(Para);
    
    record   = zeros(1, Para.totaltime);  
    record0  = zeros(1, Para.totaltime); 
    initFes  = zeros(1, Para.totaltime);
    
    FbestRec = zeros(Para.totaltime, Para.maxEvaluations);

    RA = zeros(Para.totaltime, Para.maxEvaluations);

    quench = 2;

    for run = 1 : Para.totaltime

        Rmax = Para.lu(2,:) - Para.lu(1,:);

        Para.evaluations = 0;
        C = 1;

        s_ins = 0;
        s_rep = 0; 
        s_del = 0;
        f_ins = 0; 
        f_rep = 0;
        f_del = 0;

        rr = 0;
        rc = 1;
        
        while C~=0
            UAVPosition0 = repmat(Para.lu(1, :), Para.NSP, 1) + rand(Para.NSP, length(Para.lu)) .* (repmat(Para.lu(2, :) - Para.lu(1, :), Para.NSP, 1));
    
            [initVal, C] = Fitness(UAVPosition0, Data.IoTPosition, Para, Data);
            Para.evaluations = Para.evaluations + 1;
            initFes(run) = Para.evaluations;
            if(initFes(run) > Para.maxEvaluations)
                disp("error")
                break;
            end
        end
        if C ~= 0
            continue;
        end

        Fbest = initVal;
        f_inv = Fbest;

        UAVPosition = [UAVPosition0, zeros(Para.NSP, 2)];

        G = 0;
        while(Para.evaluations < Para.maxEvaluations) 
            NS = size(UAVPosition, 1);
            n = 3;
            Fbest = Fitness(UAVPosition(:, 1:3), Data.IoTPosition, Para, Data);
            cUnit = Para.maxEvaluations/quench; 
            R = (Rmax/2^(floor(Para.evaluations/cUnit))) * mod((Para.maxEvaluations - Para.evaluations), cUnit) / cUnit;

            if(rc > 0)
                rf = 0;
                for i = NS:-1:1
                    offpop = UAVPosition;
                    offpop(i, :) = [];
                    fval = Fitness(offpop(:, 1:3), Data.IoTPosition, Para, Data);
                    if(Fbest >= fval)
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
                if(rf == 0)
                    rr = rr + 1;
                    rc = rc - rr;
                else
                    rc = rc + 1;
                end
            else
                rc = rc + 1;
            end

            ff = 0;
            offpop = UAVPosition;
            for i = 1 : size(UAVPosition, 1)
                individual = offpop(i, :);
                if(offpop(i, 4) == 0)
                    offpop(i, 1:3) = offpop(i, 1:3) + (rand(1,n)*2-1).*R;
                else
                    offpop(i, 1:3) = offpop(i, 1:3) + [offpop(i, 4:5), 0] .* rand(1,3);
                end
                fval = Fitness(offpop(:, 1:3), Data.IoTPosition, Para, Data);

                if(Fbest > fval)
                    A = offpop(i, 1:2) - individual(1:2);
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
            UAVPosition = offpop;

            if(Para.print)
                if(ff == 1)
                    fprintf("■")
                else
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
            fprintf("%d  replace：%d  delete：%d\n", s_ins, s_rep, s_del);
            fprintf("%d  replace：%d  delete：%d\n", f_ins, f_rep, f_del);
            fprintf("%f - %f - %f- %f = %f\n", f_inv, f_ins, f_rep, f_del, f_inv-f_ins-f_rep-f_del);
        end
        fprintf("%-15s，%d running，optimal %f，total %d\n", Para.name, run, Fbest, G);
        
    end
    time = toc;
    if Para.save
        save(Para.name);
    end
    
end
    