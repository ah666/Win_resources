function Cfo_data1=cfo_correct(Cfo_data)
% correct carriers frequence offset
% input Cfo_data
% output Cfo_data1
%% carriers frequence offset Estimation 
conj_Cfo_data=conj(Cfo_data);
cita1 =0;%���Ƶƫ��������Ǳ仯
n=3;   %n+1Ϊ���Ÿ���
N=2560;%���ų��ȣ�����ѭ��ǰ׺
K=2048;%IFFT����
L=512;%ѭ��ǰ׺
long=length(Cfo_data);
for i=0:n
n1=1+N*i;
cita1 =cita1 +angle(sum(Cfo_data(n1:n1+L-1).*conj_Cfo_data(n1+K:n1+K+L-1))) /(2*pi);
end
%% carriers frequence offset correct
Cfo_data1=Cfo_data.*exp(1i*2*pi*(cita1/(n+1))*(1:long)/K);
end