clear all;
clc;

N = 2^15;
interval = 1e-3;
% freq = (-N/2:N/2-1)*interval;

omega_0 = 7;
deltaOmega_g = 1;
omega = (-N/2:N/2-1)*interval+omega_0;

% Gaussion
% g = exp(-4*log(2)*freq.^2);
g = exp(-4*log(2)*((omega-omega_0)/deltaOmega_g).^2);

% Lorentzian 
% g1 = 1/(2*pi)./((1/2)^2+freq.^2);
g1 = deltaOmega_g/(2*pi)./((deltaOmega_g/2)^2+(omega-omega_0).^2);

% -------------- Display the results ---------
close all
freq = (omega-omega_0)/deltaOmega_g;
plot(freq, g);
hold on
plot(freq, g1);
