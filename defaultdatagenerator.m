
t = 0.020;      % s (time of sample)
fs = 2000;      % hz (sample frequentie)
n = 0:t*fs-1;   % sample

f1 = 50;                    % hz (component frequency)
A1 = 230*sqrt(2);           % amplitude
s1 = A1*sin(f1*n/fs*2*pi);  % generate component

signal = s1;                % create signal by adding components
plot(n,signal);             % plot signal

fft_output = fft(signal);
fft_output = abs(fft_output);
fft_output = fft_output/fs;
fft_output = fft_output(1:length(signal)/2+1);
fft_output(1) = fft_output(1)/2;
f = fs*(0:(length(signal)/2))/length(signal);
%stem(f,fft_output);         % plot fft

filename = './data/defaultdata.xlsx';                   % set filename 
xlswrite(filename,transpose(signal),'Blad1','A12');     % write signal to file
xlswrite(filename,fs,'Blad1','A9');                     % write sample frequency to file