clear all;
clc;

N = 2^15;
interval = 1e-3;

omega_0 = 0;
deltaOmega_g = 1;
% deltaOmega_s = sqrt(1/12);	% critical point
deltaOmega_s = 1;	% SML
omega = (-N/2:N/2-1)*interval+omega_0;

% Gaussion
g  = exp(-4*log(2)*((omega-omega_0)/deltaOmega_g).^2);
gs = 1/2*(exp(-4*log(2)*((omega-omega_0+deltaOmega_s)/deltaOmega_g).^2) + ...
          exp(-4*log(2)*((omega-omega_0-deltaOmega_s)/deltaOmega_g).^2));

% Lorentzian 
g1  = deltaOmega_g/(2*pi)./((deltaOmega_g/2)^2+(omega-omega_0).^2);
g1s = 1/2*deltaOmega_g/(2*pi)*(1./((deltaOmega_g/2)^2+(omega-omega_0+deltaOmega_s).^2) + ...
                               1./((deltaOmega_g/2)^2+(omega-omega_0-deltaOmega_s).^2));

% -------------- Record the results ---------
freq = (omega-omega_0)/deltaOmega_g;
% if exist('Data.txt','file')
% 	delete('Data.txt');
% end
% fid=fopen('Data.txt','a+');
fid=fopen('Data.txt','w');
% fprintf(fid,'This is the data file!\r\n');
% fprintf(fid,'%f\t%f\r\n',freq,g1s);
for iii = 1:1:N
	fprintf(fid, '%f\t%f\r\n',freq(iii), g1s(iii));
end
fclose(fid);

% -------------- Display the results ---------
close all
% plot(freq, g);
% plot(freq, gs);
% hold on
% plot(freq, g1);
plot(freq, g1s);
