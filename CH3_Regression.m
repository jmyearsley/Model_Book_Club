%% Code to estimate regression parameters, based on Chapter 3 of Farrell & Lewandowsky.
% If you want to try the simulated annealing you need to install the Global
% Optimization Toolbox

% Basic data parameters
rho = .8;
intercept = 1;
nDataPts = 20;

% Generate Synthetic Data
data = zeros(nDataPts,2);
data(:,2) = random('Normal',0,1,nDataPts,1);
data(:,1) = random('Normal',0,1,nDataPts,1)*sqrt(1.0-rho^2)+data(:,2)*rho + intercept;

%Do conventional regression analysis
fitlm(data(:,2),data(:,1))

% Now do numerical optimization
x0=[-1 .2];
xout = fminsearch(@(parms)rmsd(parms,data),x0) % This is the MatLab version of the Simplex solver. For funny @ thing see footnote.

%options = optimoptions(@simulannealbnd,'ReannealInterval', 1000);
%xout = simulannealbnd(fun,x0,[-3 -1],[3 1],options) % MatLab version of Simulated Annealing. 


%% Defining the getregpred, and rmsd functions. 
% These have to come at the end of a script in MatLab, although it would
% be best practice to define them in seperate files.
function [regpred]= getregpred(parms, data)
regpred = parms(1) + parms(2)*data(:,2);

figure(1) % Plot the data and current solution
plot(data(:,2),data(:,1),'ok')
hold on
line(data(:,2),regpred)
axis([min(data(:,2))-1  max(data(:,2))+1 min(data(:,1))-1 max(data(:,1))+1])
hold off
end

function [rmsdout] =  rmsd(parms,data)
preds = getregpred(parms,data);
rmsdout = sqrt(sum((preds - data(:,1)).^2)/length(preds));
end

%% Footnote
% Matlab and R handle functions in slightly different ways. 
% One difference is that in MatLab functions have their own workspaces and 
% don't see other variables unless you explicitly pass them to the fuction. 
%
% The function 'rmsd' in Farrell & Lewandowsky is defined as a function of 
% both params and data1, but in the optim function it is being thought of as
% a function of just params, with data1 held fixed. 
%
% There are various ways of getting the same effect in MatLab, but the
% easiest is probably to define a new (anonymous) function to be
% passed to the optimizer that has a single input parameter params, and
% whos value is equal to rmsd(params, data). We do that with this funny @
% symbol. Magic.