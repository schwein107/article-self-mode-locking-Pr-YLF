% CHAPTER 6.2.1
% MLLsimple.m
% simple model of mode locked laser
% written by Saiyu Luo
clear;
clc;

global Ts;			% sampling period
global Fcar;		% carrier frequency (optical frequency)
c_const = 3e8;		% speed of light

lamda = 639.45e-9;	% m
Fcar = c_const/lamda;

Ts = 0.01e-12;		% 0.01 ps
N = 2^13;			% number of samples in a block. Tblk = N * Ts = 102.4 ps

% Amplifier parameters:
  GssdB = 15;		% (dB)
  PoutsatdB = 10;	% (dBm)
  % NF = 8;			% (dB)

% filter bandwidth
  lamda3dB = 0.69e-9;	% m
  % f3dB = lamda3dB*(1e11/0.8e-9);  % for lamda = 1550e-9
  f3dB = lamda3dB*c_const/lamda^2;  % for arbitrary lamda

% filter order
    n=1;
% the percentage of gain line splitting compared with all N points
    % shift = 1.8;             % %
    shift = 0.176;             % %
    shift = N*shift/100;    % amount of index

% modulator parameters
  % alpha = -0.07;
  % epsilon = 40;		% (dB) extinction ratio
  
% modulation parameters
    % duration = 45.1e-12;    % 45.1 ps
    duration = 45e-12;    % 45.1 ps
  %% m = 15000;			% modulation index, by increasing it, the spectra is broadened, and the pulse is shortened.
                    % it can be considered as a magnification factor of fm
  %% fm = 93e6;		% modulation frequency, 
                    % by increasing it, the shape will be narrowed
                    % when it is small than f3dB, when increasing it, the spectra is broadened and the pulse is shortened.
                    % while it exceed f3dB, it will only modulate single frequency, pulse will not form.

% Loss
  loss = 10;			% dB
  atten = 1/10^(loss/20);

% generate an initial block of signal Ein
% Generate an N-by-1 matrix of complex white Gaussian noise having power -40 dBW. 
Ein = wgn(N,1,-40,'complex');

Eout = Ein;
Eo = Ein;
N_pass = 2000;
for ii = 1:N_pass
    %% fprintf('----------------------------\n', ii);
    %% fprintf('pass %d begin\n', ii);
	[Eo,G] = AmpSimpNonoise(Eo,GssdB,PoutsatdB); % no noise
	Eo = fft(Eo);
	% Eo = filter_gaus(Eo,f3dB,n);  % multiply by a gaussian filter in the frequency domain, which is equivalent to convolve by a gaussian filter in the time domain.
	% Eo = filter_gaus_stark_shift(Eo,f3dB,shift);
	Eo = filter_lorentz_stark_shift(Eo,f3dB,shift);
	Eo = ifft(Eo);

	% Eo = modInt(Eo(1:N),alpha,epsilon,m,fm,0.5);
	% Eo = modInt_theory(Eo(1:N),m,fm);     % Eo(1:N) is a abbreviation for Eo(1:N,1), which represents the 1'th row to the N'th row, 1th column.
                                            % A(a:b,c:d) represents the overlay of a'th row to b'th row and c'th column to d'th column.
                                            % multiply by a gaussian-like filter in the time domain

	% Eo = modInt(Eo,alpha,epsilon,m,fm,0.5);
	Eo = modInt_theory(Eo,duration);    

	Eo = Eo*atten;
	% if mod(ii,N_pass/50)==0 % display part of the N_pass
		Eout = [Eout, Eo];  % add Eo to Eout. including noise, so the column of Eout is one more.
	% end
    %% fprintf('pass %d end\n', ii);
    %% fprintf('----------------------------\n', ii);
end
Eout = Eout/atten;
close all

% -------------- Display the results ---------
% mesh (abs(Eout'),'edgecolor','black','meshstyle','row', 'facecolor','none');
Iout = Eout.*conj(Eout);
Iout = Iout/max(Iout(:,N_pass+1));  % normalization
% save Iout.txt -ascii Iout;
time_plot_index = 1500;
% time = ((1:N)-N/2)*Ts;    % plot all
time = (-time_plot_index/2:time_plot_index/2)*Ts *1e12; % ps
Iout_time_index = (-time_plot_index/2:time_plot_index/2)+N/2;
mesh (time,(1:N_pass+1),Iout(Iout_time_index,:)','meshstyle','row','facecolor','none');
%% mesh (time,(1:N_pass+1),Iout','meshstyle','row','facecolor','none');
axis tight;

fontSize = 15;
set(gca,'XTick',[-7:2:7]);
% set(gca,'XTickLabel',tt_tick);
% set(gca,'XDir','reverse');
xlabel('t (ps)', 'FontSize',fontSize);

% set(gca,'YTick',yy_mark);
% set(gca,'YTickLabel',yy_tick);
ylabel('Pass number', 'FontSize',fontSize);

set(gca,'ZTick',[0:0.5:1]);
% zlabel('intensity (W)');
zlabel('Intensity (arb.unit)','FontSize',fontSize);

N1 = size(Eout,2);
% N1 = 5;
% dPhi = angle(Eout(2:N,N1)) - angle(Eout(1:N-1,N1));
% figure (2);
% plot(dPhi);
% plot(fftshift(dPhi));

% return the Full Width at Half Maximum of the pulse x
% Tp = fwhm(Iout(:,N1))*Ts;
% pulse_alpha = 2*log(2)/(Tp^2);
% pulse_beta = (dPhi(N/2+100) - dPhi(N/2-100))/200/Ts/Ts;
%  chirp = pulse_beta/pulse_alpha

Kmag = 4;   % this factor is proportional to the refinement (interval between points) of the transformed frequency data;
            % the total frequency range is determined by the total time range and will not be changed. By changing Kmag, we are changing the number of points in the frequency domain, thus the refinement.
Nplot = 1000;    % plotted frequency points, it determines the plotted frequency range, not the refinement. 
                % this factor is related to the index of the frequency points
Eoutfreq = fft(Eout(:,N1),N*Kmag);  % take the last pulse and transform it to frequency domain
Ioutfreq = Eoutfreq.*conj(Eoutfreq)/(N*Kmag)^2;

figure(2);
ind = (- Nplot/2 : Nplot/2)';   % index
delta_freq = 1/(Ts*N*Kmag); % it determines the refinement in the frequency domain.
% freq = ind/Ts/N/Kmag;
freq = ind*delta_freq;
ind = mod((ind + N*Kmag),N*Kmag)+1; % this step just turn index into positive ones, and complete the fftshift step;
                                    % if not pluse 1, index will contain 0, but the indices of MATLAB must be real positive integers.
Ioutfreq = Ioutfreq/max(Ioutfreq);  % normalization                                    
plot(freq,Ioutfreq(ind));

n = 2*n;

shift = shift * Kmag;    % freq is actually be refined, so we should tune shift fitst by multiplying with Kmag
% Tfil = (exp(-log(2)*(2/f3dB*(freq-shift*delta_freq)).^n)+exp(-log(2)*(2/f3dB*(freq+shift*delta_freq)).^n))/2;
Tfil = 1./((f3dB/2)^2+(freq-shift*delta_freq).^2) + ...
       1./((f3dB/2)^2+(freq+shift*delta_freq).^2); 
Tfil = Tfil/max(Tfil);  % normalization
hold on
plot(freq,Tfil,'r');
% freq_Tfil = [freq, Tfil];
% save freq_Tfil.txt -ascii freq_Tfil;

figure(3)
wavelength = c_const./(freq+Fcar);
plot(wavelength,Ioutfreq(ind));
hold on
plot(wavelength,Tfil,'g')
hold on
% -------------- Read spectrum from data ---------
Data = load('Measured spectrum.txt');
plot(Data(:,1)*1e-9, Data(:,2),'r');

% export gain line and fitted spectral
gain_line = [wavelength*1e9,Tfil];
save Lorentzian_gain_line.txt -ascii gain_line;
stimulated_spectrum = [wavelength*1e9,Ioutfreq(ind)];
save stimulated_spectrum.txt -ascii stimulated_spectrum;

% plot the gaussian fit curve
% gaussFit(Iout(:,N1));

pulseBW = fwhm(Ioutfreq(ind))/Ts/N/Kmag
pulseDeltaLamda = c_const/Fcar^2*pulseBW *1e9    % nm
Tp = fwhm(Iout(:,N1))*Ts*1e12   % ps
TBP = pulseBW*Tp/1e12
