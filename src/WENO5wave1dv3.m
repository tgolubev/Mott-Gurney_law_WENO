%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Solving Poisson + Mott-Gurney limit system (for holes) with 5th order
%             Weighted Essentially Non-Oscilatory (WENO5)
%
%                E*dp/dx + p*dE/dx = 0  for x in [0,L]
%                  
%            
% Modified by Timofey Golubev (2017.08.06) based on original 1D wave eqn
%              code by Manuel Diaz, manuel.ade'at'gmail.com 
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
L = 10*10^-9;              %device length in meters
num_cell = 500;            % number of cells
p_initial =  10^(27);      %initial hole density

Va_min = 30.0;             %volts
Va_max = 30.5;    
V_increment = 0.01;        %for increasing V
Ea_min = Va_min/L;         %V/m
Ea_max = Va_max/L;         %maximum applied E
increment = V_increment/L; %for increasing E

%Simulation parameters
tolerance = 10^-14;   %error tolerance       
fluxsplit = 3;        % {1} Godunov, {2} Global LF, {3} Local LF  Defines which flux splitting method to be used

%% Physical Constants
q =  1.60217646*10^-19;         %elementary charge, C
epsilon_0 =  8.85418782*10^-12; %F/m
epsilon = 3.8*epsilon_0;        %dielectric constant of P3HT:PCBM

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
a=0; b=L; x0=linspace(a,b,num_cell); dx=(b-a)/num_cell;   %x0 is positions array
% Depending on the degree of the WENO stencil we are using, 2 more ghost
% will have to be added to the final domain.

x= [-2*dx,-dx,x0,b+dx,b+2*dx];   %array of 5 points which will be used to estimate dJ/dx
nx = length(x)+1;  %number of x points = num_cell + 4 ghost pts + 1 (# of pts = # of cells +1)

%% Initial Conditions
%matlab indices can't start with 0 so p(x=0) corresponds to i=1
for i = 1:3
    p(i) = p_initial;
end

for i = nx-1:nx
    p(i) = 0;
end
    
for i = 1:nx-3      
    %linearly decreasing p
    dp = p_initial/(num_cell+2);
    p(i+1) = p(i)-dp;
end

for Ea = Ea_min:increment:Ea_max
    
    %Boundary conditions
    %because need 2 ghost points to left and right and matlab indices arrays from 1, means that E(x=0) =
    %E(i=3). And E(nx-2) = E(x=L)
    E(1) = 0;
    E(2) = 0;
    E(3) = Ea;
    
    %right side boundary will be determined by Newton's method solving of
    %Poisson eqn.

    %% Solver Loop
    iter = 0;
    error_p =  1.0;
    while error_p > tolerance
        
        %Poisson equation with Newton's method
        for i = 3:nx-3       %only solve for E inside the device (points 1,2, nx-1, and nx are outside device. point 3 is used to enforce E(x=0) = 0 BC.
            E(i+1) = E(i) + (q/epsilon)*p(i)*dx;   %means with initial constant p(i), this will be linear
        end
        
        %Define E at right side ghost points
        E(nx-1) = E(nx-2);
        E(nx) = E(nx-2);

        for i = 4:nx-3        %only solve for the points inside the boundaries!   start at 4 b/c at 3 E = 0 so divide by 0 issue in p calculation
            %dE = weno approx for dE/dx
            dE = residual(E,flux,dflux,dx,nx,fluxsplit);
 
            old_p = p;
  
            p(i+1) = p(i) + dx*(-p(i)/E(i))*dE(i);   %there's divide by 0 issue here if E(i) = 0
            
            error_p = max(abs(p-old_p)/old_p);

            %stop run if NaN
            if isnan(p(i))
                stopstatement
            end

        end
        
        %adjust BC's for p
        %p(1) = 0;
        %p(2) = 0;
        %p(3) = p_initial;   %for conservation of particles
        for i=1:3
            p(i) = p_initial;
        end
           p(nx) = 0;%p(nx-2);
           p(nx-1) = 0;% p(nx-2)
           p(nx-2) = 0;
        
    iter =  iter+1;
        
    end
        for i = 3:nx-2 
            Jp(i) =  q*p(i)*E(i);
        end
    Ea
    
end
%% Final Plot
 %plot(x(3:152),p(3:152))
 plot(x(3:152),E(3:152))
 %plot(x(3:152),Jp(3:152))


% plot(x,u0,'-x',x(domain),u(domain),'-'); 
% axis([a,b,min(u0)-0.1,max(u0)+0.1])
% title('WENO5, Cell Averages plot','interpreter','latex','FontSize',18);
% xlabel('$\it{x}$','interpreter','latex','FontSize',14);
% ylabel({'$\it{u(x)}$'},'interpreter','latex','FontSize',14);