clear all;
clc;

N = 2^15;
interval = 1e-3;

omega_0 = 7;
deltaOmega_g = 1;
deltaOmega_s = 1;
omega = (-N/2:N/2-1)*interval+omega_0;

% Gaussion
g  = exp(-4*log(2)*((omega-omega_0)/deltaOmega_g).^2);
gs = 1/2*(exp(-4*log(2)*((omega-omega_0+deltaOmega_s)/deltaOmega_g).^2) + ...
          exp(-4*log(2)*((omega-omega_0-deltaOmega_s)/deltaOmega_g).^2));

% Lorentzian 
g1  = deltaOmega_g/(2*pi)./((deltaOmega_g/2)^2+(omega-omega_0).^2);
g1s = 1/2*deltaOmega_g/(2*pi)*(1./((deltaOmega_g/2)^2+(omega-omega_0+deltaOmega_s).^2) + ...
                               1./((deltaOmega_g/2)^2+(omega-omega_0-deltaOmega_s).^2));

% -------------- Display the results ---------
close all
freq = (omega-omega_0)/deltaOmega_g;
plot(freq, g);
plot(freq, gs);
hold on
plot(freq, g1);
plot(freq, g1s);
