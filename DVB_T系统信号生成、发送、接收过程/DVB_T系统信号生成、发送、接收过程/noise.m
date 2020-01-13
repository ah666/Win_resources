function Rx_data=noise(Tx_data,SNR)
% input Tx_data 初始信号  SNR信噪比
% output Rx_data
n=size(Tx_data,1);
m=size(Tx_data,2);
Tx_signal_power = var(Tx_data,0,2);% 计算信号功率,即方差
linear_SNR=10^(SNR/10);% 转换对数信噪比为线性幅度值
noise_sigma=Tx_signal_power/linear_SNR;%计算噪声功率，也就是方差
noise_scale_factor = sqrt(noise_sigma);% 计算标准差
noise=zeros(n,m);
for i=1:n
noise(i,:)=randn(1,m).*noise_scale_factor(i);% 产生功率为noise_scale_factor高斯噪声
end
Rx_data=Tx_data +noise;%在发送数据上加噪声，相当于OFDM信号经过加性高斯白噪声信道。
end