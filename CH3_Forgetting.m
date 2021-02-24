%% Code to fit power model of forgetting to data from Carpenter et al (2008)
% Based on R code in Chapter 3 of Farrell & Lewandowsky

% Carpenter et al (2008) Experiment 1
rec=[ .93 .88 .86 .66 .47 .34];
ri=[.0035 1 2 7 14 42];

% Initialize starting values
sparms = [1 .05 .7];

% Obtain best-fitting estimates
pout = fminsearch(@(parms)powdiscrep(parms, rec, ri),sparms);
% Compute power law forgetting function with the best-fitting parameters
% I do this differently in order to capture the first time point properly
pow_pred = pout(1)*(pout(2).*[0 .00350 1:max(ri)]+1).^(-pout(3));

%Plot Data and best-fitting estimates
figure(1)
plot(ri,rec,'ok','MarkerFaceColor','k')
hold on
plot([0 .0035 1:max(ri)],pow_pred,'-k')
hold on
xlabel('Retention Interval (Days)')
ylabel('Proportion Items Retained')
axis([-1 43 .3 1])
% Slightly cumbersome vanity code to get the lines between data point and
% curve
for i=1:length(ri)
    line([ri(i) ri(i)],[rec(i) pow_pred(find([0 .0035 1:max(ri)]==ri(i)))],'Color','black')
    hold on
end
xticks([0:3:max(ri)])
set(gca,'FontSize',15)

%% Perform bootstrapping analysis
ns = 55; % Number of people
nbs = 1000; % How many times to sample
bsparms = NaN(nbs,length(sparms));
bspow_pred = pout(1)*(pout(2).*ri+1).^(-pout(3));
for i=1:nbs
    recsynth = random('Binomial',ns,bspow_pred)/ns; % ees ok.
    bsparms(i,:)= fminsearch(@(parms)powdiscrep(parms,recsynth,ri),sparms);
end

%% Plot Histograms of bootstrapped parameter values
figure(2)
labs={'a' 'b' 'c'};
for i = 1:length(bsparms(1,:))
subplot(1,length(bsparms(1,:)),i)
h=histogram(bsparms(:,i));
hold on
order(i,:) = sort(bsparms(:,i));
line([order(i,round(length(bsparms(:,i))*.025)) order(i,round(length(bsparms(:,i))*.925));order(i,round(length(bsparms(:,i))*.025)) order(i,round(length(bsparms(:,i))*.925)) ],[0 0 ;max(h.Values)+10 max(h.Values)+10],'Color','k','LineStyle','--')
hold on
ylabel('Frequency')
xlabel(labs(i))
xlim([0 1])
ylim([0 inf])
end

%% Output best fitting parameter values and 95% Bootstrapped confidence intervals
fprintf('Estimate of a= %.3f, 95%%CI= [%.3f, %.3f]\n',pout(1), order(1,round(length(bsparms(:,1))*.025)),order(1,round(length(bsparms(:,1))*.925)))
fprintf('Estimate of b= %.3f, 95%%CI= [%.3f, %.3f]\n',pout(2), order(2,round(length(bsparms(:,2))*.025)),order(2,round(length(bsparms(:,2))*.925)))
fprintf('Estimate of c= %.3f, 95%%CI= [%.3f, %.3f]\n',pout(3), order(3,round(length(bsparms(:,3))*.025)),order(3,round(length(bsparms(:,3))*.925)))

%% Discrepancy for power forgetting function
%  Function definitions come at the end in MatLab
function [discrep] = powdiscrep(parms, rec, ri)
 if any(parms <0| parms>1)
     discrep=1E6; % Penalise if any paramters outside the range.
 else
     pow_pred=parms(1)*(parms(2)*ri +1).^(-1*parms(3));
     discrep=sqrt(sum((pow_pred-rec).^2)/length(ri));
 end
end
   