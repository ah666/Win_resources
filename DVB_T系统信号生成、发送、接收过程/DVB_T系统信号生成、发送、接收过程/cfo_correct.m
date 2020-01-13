function Cfo_data1=cfo_correct(Cfo_data)
% correct carriers frequence offset
% input Cfo_data
% output Cfo_data1
%% carriers frequence offset Estimation 
conj_Cfo_data=conj(Cfo_data);
cita1 =0;%存放频偏产生的相角变化
n=3;   %n+1为符号个数
N=2560;%符号长度，包括循环前缀
K=2048;%IFFT个数
L=512;%循环前缀
long=length(Cfo_data);
for i=0:n
n1=1+N*i;
cita1 =cita1 +angle(sum(Cfo_data(n1:n1+L-1).*conj_Cfo_data(n1+K:n1+K+L-1))) /(2*pi);
end
%% carriers frequence offset correct
Cfo_data1=Cfo_data.*exp(1i*2*pi*(cita1/(n+1))*(1:long)/K);
end