%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Solving Poisson + Mott-Gurney limit system (for holes) with 5th order
%             Weighted Essentially Non-Oscilatory (WENO5)
%
%                E*dp/dx + p*dE/dx = 0  for x \in [0,L]
%                  
%
%            
%       Modified by Timofey Golubev based on original code of 1D wave eqn
%                 by Manuel Diaz, manuel.ade'at'gmail.com 
%              Institute of Applied Mechanics, 2012.08.20
%                               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ref: Jiang & Shu; Efficient Implementation of Weighted ENO Schemes
% JCP. vol 126, 202-228 (1996)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notes: Finite Difference Implementation of WENO5 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;

%% Parameters
      cfl = 0.30;   % Courant Number
       L = 70;      %device length 
       nx = 150;    % number of cells
       
  BC_type = 3;      % {1} Dirichlet, {2} Neumann, {3} Periodic   !THIS SEEMS TO BE NEVER USED
fluxsplit = 3;      % {1} Godunov, {2} Global LF, {3} Local LF  Defines which flux splitting method to be used

p_initial =  10^(-3);   %initial hole density
Ea_min = 1;
Ea_max = 2;               %maximum applied E
increment = 0.01;         %for increasing E

%% Physical Constants
q =  1.60*10^-16;
epsilon_0 =  8.854*10^-12;
epsilon = 3.8*epsilon_0;


%% Define our Flux function
fluxtype = 'linear';

%These @(w) define flux and dflux as function handles, allowing to call
%functions indirectly within arguments of calls to other functions as done
%in residual().
switch fluxtype
    case 'linear'
        c=1; flux = @(w) c*w;
        dflux = @(w) c*ones(size(w));
    case 'nonlinear' % Burgers'
        flux = @(w) w.^2/2;
        dflux = @(w) w;
end

% Domain Discretization
a=0; b=L; x0=linspace(a,b,nx); dx=(b-a)/nx;   %x0 is positions array
% Depending on the degree of the WENO stencil we are using, 2 more ghost
% will have to be added to the final domain.
%x is the array of 5 points which will be used to estimate dJ/dx
x= [-2*dx,-dx,x0,b+dx,b+2*dx]; nx = length(x)+1;  %THIS ADDS THE GHOST POINTS 2 TO LEFT AND 2 TO RIGHT OF THE ARRAY X0 and REDEFINES NX to = nx+5 (4 ghost pts + fact that number of points = number of cells+1!
%So if nx=150, size(x) = 154



% Initial Conditions
for i = 1:nx       %matlab indices can't start with 0
    p(i) = p_initial;
    %E0(i) = i*dx*Ea/nx;   %Assume linear initial E 
end

for Ea = Ea_min:increment:Ea_max
    
    %Boundary conditions
    %because need 2 ghost points to left and right and matlab indices arrays from 1, means that E(x=0) =
    %E(i=3). And E(nx-2) = E(x=L)
    E(1) = 0;
    E(2) = 0;
    E(3) = 0;
    
    %right side boundary will be determined by Newton's method solving of
    %Poisson eqn.


%     % Plot range
%     domain = 3:nx-2; % don't show gost cells
%     plotrange = [a,b,min(u0)-0.1,max(u0)+0.1];

    %% Solver Loop
    %Poisson equation with Newton's method
    for i = 3:nx-2       %only solve for E inside the device (points 1,2, nx-1, and nx are outside device. point 3 is used to enforce E(x=0) = 0 BC.
        E(i+1) = E(i) + (q/epsilon)*p(i)*dx;   %means with initial constant p(i), this will be linear
    end
    
    E(nx-1) = E(nx-2);
    E(nx) = E(nx-2);
    E
    
    

    
    for i = 1:nx
        %dE = weno approx for dE/dx
        dE = residual(E,flux,dflux,dx,nx,fluxsplit);
        %size(dE)   %RIGHT NOW dE has 156 elements and p has 155 have size mathcing  issue.
        
        %to fix divide by 0 issue
       % for j =  1:nx
            if dE(i) == 0
                p(i+1) = p(i);
                continue
            end
       
        p(i+1) = p(i) + dx*(-p(i)/E(i))*dE(i);   %THEER'S A DIVIDE BY 0 ISSUE HERE!! FOR WHEN E is 0.
        
        if isnan(p(i))
            exit
        end
       
    end
    
     
  
end
%% Final Plot
% plot(x,u0,'-x',x(domain),u(domain),'-'); 
% axis([a,b,min(u0)-0.1,max(u0)+0.1])
% title('WENO5, Cell Averages plot','interpreter','latex','FontSize',18);
% xlabel('$\it{x}$','interpreter','latex','FontSize',14);
% ylabel({'$\it{u(x)}$'},'interpreter','latex','FontSize',14);