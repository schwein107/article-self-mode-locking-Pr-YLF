% figure(4)
factor = 1.24;
tuned_wavelength = (Data(:,1)-lamda*1e9)*factor+lamda*1e9;
plot(tuned_wavelength,Data(:,2),'r')
hold on
plot(wavelength*1e9,Ioutfreq(ind),'b')
tuned_measured_spectrum = [tuned_wavelength,Data(:,2)];
save tuned_measured_spectrum.txt -ascii tuned_measured_spectrum;
