%% This example is available at http://www.mathworks.com/help/optim/examples/tutorial-for-the-optimization-toolbox.html?prodcode=ML

% Consider the problem of finding a minimum of the function:
f = @(x,y) x.*exp(-x.^2-y.^2)+(x.^2+y.^2)/20;

% Plot the function to get an idea of where it is minimized
% The plot shows that the minimum is near the point (-1/2,0).
ezsurfc(f,[-2,2])

% define the objective function to minimize
fun = @(x) f(x(1),x(2));

% Take a guess at the solution:
x0 = [-.5; 0];

% Set optimization options to not use fminunc's default large-scale 
% algorithm, since that algorithm requires the objective function gradient 
% to be provided:
options = optimoptions('fminunc','Algorithm','quasi-newton');

% Call fminunc, an unconstrained nonlinear minimizer:
[x, fval, exitflag, output] = fminunc(fun,x0,options);

% The solver found a solution at:
uncx = x

% The function value at the solution is:
uncf = fval