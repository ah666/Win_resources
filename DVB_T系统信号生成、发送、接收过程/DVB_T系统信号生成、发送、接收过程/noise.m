function Rx_data=noise(Tx_data,SNR)
% input Tx_data ��ʼ�ź�  SNR�����
% output Rx_data
n=size(Tx_data,1);
m=size(Tx_data,2);
Tx_signal_power = var(Tx_data,0,2);% �����źŹ���,������
linear_SNR=10^(SNR/10);% ת�����������Ϊ���Է���ֵ
noise_sigma=Tx_signal_power/linear_SNR;%�����������ʣ�Ҳ���Ƿ���
noise_scale_factor = sqrt(noise_sigma);% �����׼��
noise=zeros(n,m);
for i=1:n
noise(i,:)=randn(1,m).*noise_scale_factor(i);% ��������Ϊnoise_scale_factor��˹����
end
Rx_data=Tx_data +noise;%�ڷ��������ϼ��������൱��OFDM�źž������Ը�˹�������ŵ���
end