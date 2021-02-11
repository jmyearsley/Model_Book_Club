%% Random Walk Model with trial-to-trial start point and drift variability. 
% Based on code in Chapter 2 of Farrell & Lewandowsky. Requires statistics and machine learning toolbox.
nreps = 1000;
nsamples = 2000;

drift = 0.03;
sdrw = 0.3;
criterion = 3;
t2tsd = [0.8 0];                            % Trial to trial variability in start point and drift rate

latencies = zeros(1,nreps);
responses = zeros(1,nreps);
evidence = zeros(nreps,nsamples+1);
for i=1:nreps
    sp = random('Normal',0,t2tsd(1));         % Choose start point for this trial
    dr = random('Normal',drift,t2tsd(2));     % Choose drift rate for this trial
    evidence(i,:) = cumsum(cat(2,sp,random('Normal',dr,sdrw,1,nsamples))); 
    p = find(abs(evidence(i,:))>criterion,1); % Find the first value in evidence list which exceeds criterion
    responses(i) = sign(evidence(i,p));       % Did the walk hit the top or the bottom?
    latencies(i) = p;                         % When did it reach criterion?
end

%% Plotting. This looks a little different from F&L because of the different ways R and MatLab handle plots

tbpn = min(nreps,5);                          % How many examples to plot?

figure(1)
xend=(max(latencies(1:tbpn))+10);             % How big do I need to make the x axis?
for i=1:tbpn
    plot(evidence(i,1:(latencies(i))),'-')    % Plot each evidence list up to the time it hits crierion
    hold on
end
line([0,xend],[criterion,criterion])
hold on
line([0,xend],[-criterion,-criterion])
xlim([1,xend])
ylim([-criterion-.5,criterion+.5])
xlabel('Steps ~ "Time"')
ylabel('Evidence')
title('A Sample of the Random Walks')

figure(2)
edges=0:50:max(latencies);
subplot(2,1,1)
toprt = latencies(responses>0);               % Pick the latencies for cases where walk hits the top criterion
topprop = length(toprt)/nreps;                % What proportion is that?
histogram(toprt,'FaceColor',[.6 .6 .6],'BinEdges',edges)       % Draw a historgram
xlabel('Decision Time')
xlim([0,max(latencies)])
title(sprintf('Top Responses ( %.3f ) m=%.1f',topprop,mean(toprt))) % Fancy title with proportion and mean RT

subplot(2,1,2)
botrt = latencies(responses<0);               % Rinse and repeat for the bottom criterion
botprop = length(botrt)/nreps;
histogram(botrt,'FaceColor',[.6 .6 .6],'BinEdges',edges)
xlabel('Decision Time')
xlim([0,max(latencies)])
title(sprintf('Bottom Responses ( %.3f ) m=%.1f',botprop,mean(botrt)))
