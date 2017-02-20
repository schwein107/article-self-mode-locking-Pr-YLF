function [Eout,gain] = AmpSimpNonoise(Ein,GssdB,PoutsatdB)
% amp_simp(Ein,GssdB,PoutsatdB,NF)
% simple model of optical amplifier. The model includes the gain
% saturation without noise
% written by Lam Quoc Huy

% Amplifier parameters:
%	small signal gain: GssdB (dB)
%	output saturation power: PoutsatdB (dBm)
%
% The input is a column vector containing block N samples of the optical signal sampling at the
% rate 1/Ts
% The output is calculated using
%	Eout = Ein*sqrt(G)
% where: G is the saturated gain
%		 G = Gss*exp(-(G-1)Pin/Psat) (eq1)

fprintf('small signal gain (dB): GssdB = %.1f dB\n', GssdB);
Gss = 10^(GssdB/10);
fprintf('Gss = 10^(GssdB/10) = %.1f times\n', Gss);

fprintf('output saturation power (dBm): PoutsatdB = %.1f dBm\n', PoutsatdB);
Poutsat = (10^(PoutsatdB/10))/1000;
fprintf('Poutsat = (10^(PoutsatdB/10))/1000 = %.1f mW\n', Poutsat*1e3);

Psat = Poutsat*(Gss-2)/Gss/log(2);
fprintf('saturated power level: Psat = Poutsat*(Gss-2)/Gss/log(2) = %.3f mW\n', Psat*1e3);
%Pinsat = 2* Poutsat/Gss;

N = size(Ein,1);
fprintf('length of input array: N = %d\n', N);
Pin = (sum(Ein.*conj(Ein))/N);
fprintf('Pin = (sum(Ein.*conj(Ein))/N) = %.3f mW\n', Pin*1e3);

% numerical calculation of G from the equation G = (Gss - lnG)*Psat/Pin + 1
tol = 0.05; % tolerance for G calculation
fprintf('tolerance for G calculation: tol = %.2f times\n', tol);
step = Gss/2;
fprintf('step = Gss/2 = %.1f times\n', step);
G = Gss;
fprintf('saturated gain, G = Gss = %.1f times\n', G);
err = 10;
fprintf('set initial error value, err = %.3f times\n', err);

n1 = 0;
n2 = 0;
n3 = 0;

fprintf('\nBegin loop: while (err > tol)\n\n');
while (err > tol)
    fprintf('\terr: %.3f times\n', err);
	G1 = Gss*exp(-(G-1)*Pin/Psat);
    fprintf('\tG1 = Gss*exp(-(G-1)*Pin/Psat) = %.3f times\n', G1);
    fprintf('\tG: %.3f times\n', G);
	err = G1 - G;
    fprintf('\terr = G1 - G = %.3f times\n', err);
	if err>0
		% fprintf('%05.1g times complete\n', z/flength*100);
		%һ�㸡������%f ����%e
		%f��ʾС����ʽ
		%e��ʾ��ѧ��������ʽ
		%g�����ߵ��ۺϣ����������ѡ���ʵ�����ʾ��ʽ
        fprintf('\tif err > 0\n');
		if step < 0
			fprintf('\t\tif step: %.3f times < 0\n', step);
			step = -step/2;
			fprintf('\t\t\tstep = -step/2 = %.3f\n', step);
        else
            fprintf('\t\tif step: %.3f times >= 0, do nothing\n', step);
		end
        n1 = n1 + 1;
	else
        fprintf('\tif err < 0\n');
		if step >0
			fprintf('\t\tif step: %.3f times > 0\n', step);
			step = -step/2;
			fprintf('\t\t\tstep = -step/2 = %.3f times\n', step);
        else
            fprintf('\t\tif step: %.3f times <= 0, do nothing\n', step);
		end
		err = -err;
        fprintf('\t\terr = -err = %.3f times\n', err);
        n2 = n2 + 1;
	end
	G = G + step;

    fprintf('\tG = G + step = %.3f times\n', G);
    n3 = n3 + 1;
    fprintf('\tround %d\n', n3);
    fprintf('\n');
end

fprintf('End loop\n\n');

fprintf('number of err > 0: %d;\n', n1);
fprintf('number of err < 0: %d;\n', n2);

G = G - step;
Eout = sqrt(G)*Ein;
gain = G;
end
