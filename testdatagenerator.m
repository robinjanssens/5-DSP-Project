
t = 2;          % s (time of sample)
fs = 50;        % hz (sample frequentie)
n = 0:t*fs-1;   % sample

f1 = 1;                     % hz (component frequency)
A1 = 1;                     % amplitude
s1 = A1*sin(f1*n/fs*2*pi);  % generate component

f2 = 3;                     % hz (component frequency)
A2 = 1/3;                   % amplitude
s2 = A2*sin(f2*n/fs*2*pi);  % generate component

f3 = 5;                     % hz (component frequency)
A3 = 1/5;                   % amplitude
s3 = A3*sin(f3*n/fs*2*pi);  % generate component

signal = s1 + s2 + s3;      % create signal by adding components
plot(n,signal);             % plot signal

fft_output = fft(signal);
fft_output = abs(fft_output);
fft_output = fft_output/fs;
fft_output = fft_output(1:length(signal)/2+1);
fft_output(1) = fft_output(1)/2;
f = fs*(0:(length(signal)/2))/length(signal);
%stem(f,fft_output);         % plot fft

filename = './data/testdata.xlsx';          % set filename 
xlswrite(filename,transpose(signal),'Blad1','A12');    % write signal to file
xlswrite(filename,fs,'Blad1','A9');         % write sample frequency to file