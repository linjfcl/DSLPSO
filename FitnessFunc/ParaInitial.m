function Para = ParaInitial(input)

Para.totaltime          = 1;
Para.maxEvaluations     = 10000;
Para.NSP                = 100;

Para.p      = 0.1;
Para.rho    = 1e-6;
Para.sigma  = 1e-28;
Para.B      = 1e6;
Para.ph     = 1000;
Para.F      = 0.6;
Para.CR     = 0.5;

Para.save   = false;
Para.name   = 'unnamed';

fn = fieldnames(input);
for i = 1:length(fn)
    Para.(fn{i}) = input.(fn{i});
end

end

