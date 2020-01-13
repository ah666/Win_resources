carrier_count=1705;%number of subcarriers
 symbols_per_carrier=68;
 bits_per_symbol=2;
 IFFT_bin_length=2048;%FFT个数
 PrefixRatio=1/4; 
 GI=PrefixRatio*IFFT_bin_length ;
%  Data generator (A)
 baseband_out_length = carrier_count* symbols_per_carrier* bits_per_symbol;%传输数据总bit数
 rng('default');
 baseband_out=round(rand(1,baseband_out_length));%待传输的二进制bit流
%  4QAM调制并绘制星座图
complex_carrier_matrix=qam4(baseband_out);%将baseband_out中的二进制比特流，每2比特转换为一个4QAM信号
complex_carrier_matrix=reshape(complex_carrier_matrix',carrier_count,symbols_per_carrier)';
figure(1);  
plot(complex_carrier_matrix,'*r'); 
axis([-2, 2, -2, 2]);
title('4QAM调制后星座图');
grid on

%添加离散导频
scatter_pilot=add_scattered(complex_carrier_matrix);

%添加连续导频
continue_pilot=add_continue(scatter_pilot);

% OFDM调制即IFFT调制
IFFT_modulation=[zeros(68,172) continue_pilot zeros(68,171)];
signal_after_IFFT= IFFT_bin_length.*ifft(IFFT_modulation);

%添加循环前缀
XX=zeros(symbols_per_carrier,IFFT_bin_length+GI);
for k=1:symbols_per_carrier;
        for i=1:IFFT_bin_length;
            XX(k,i+GI)=signal_after_IFFT(k,i);
        end
        for i=1:GI;
            XX(k,i)=signal_after_IFFT(k,i+IFFT_bin_length-GI);%添加循环前缀
        end
        
end
time_wave_matrix_cp=XX;%带循环前缀OFDM符号。
figure(2);
plot(0:length(time_wave_matrix_cp)-1,real(time_wave_matrix_cp(2,:)));%画带循环前缀的时域波形 
grid on;
ylabel('Amplitude');
xlabel('Time');
title('OFDM Time Signal with CP, One Symbol Period');

%加初始相位
w=0.01;
time_wave_matrix_cp1=time_wave_matrix_cp.* exp(1i*2*pi*w);

%加噪声
SNR=50;
time_wave_matrix_cp2=noise(time_wave_matrix_cp1,SNR);

%生成发送信号，并串变换
Tx_data=reshape(time_wave_matrix_cp2', (symbols_per_carrier)*(IFFT_bin_length+GI),1)';

% 载波频偏
long=length(Tx_data);
cita=1e-03;
Cfo_data=Tx_data .*exp(-1i*2*pi*cita*(1:long)/ IFFT_bin_length);%理想情况下接收到的数据


%%  最大似然方法
%计算rou
Cfo_data1=reshape(Cfo_data.',[],symbols_per_carrier).';
signal_noise=[Cfo_data1(:,513:684),Cfo_data1(:,2390:2560)];
signal_noise1=reshape(signal_noise.',[],1).';
E_signal_noise=sum(signal_noise1.*conj(signal_noise1))/343;%计算噪声的能量
location=[1,49,55,88,142,157,193,202,256,280,283,334,433,451,484,526,...
    531,619,637,715,760,766,781,805,874,889,919,940,943,970,985,1051,1102,...
    1108,1111,1138,1141,1147,1207,1270,1324,1378,1492,1684,1705];
LL=length(location);
signal_sum=Cfo_data1(:,684+location);
signal_sum1=reshape(signal_sum.',[],1).';
E_signal_sum=sum(signal_sum1.*conj(signal_sum1))/LL;%计算噪声+信号的能量
E_signal=E_signal_sum-E_signal_noise;%计算信号的能量
rou=1/(1+E_signal_noise/E_signal);

dc_m_sum=zeros(1,2560);%遍历一个符号长度
m=300;  %假设接收信号相对发射信号的初始位置
Rx_data=Cfo_data(m:174080);%接收信号
L_Rx_data=length(Rx_data);
for k=1:2560%遍历一个符号长度
 Z_data=zeros(10,512);
 Z_data1=zeros(10,512);
 dc_m=zeros(10,1);
for i= 0:9 %取10个符号进行相关
   Z_data(i+1,:)=Rx_data(k+i*2560+(0:511)); 
   Z_data1(i+1,:)=Rx_data(k+2048+i*2560+(0:511)); 
   dc_m(i+1,1)=2*abs(sum(Z_data(i+1,:).*conj(Z_data1(i+1,:))))...
-  rou*(sum(Z_data(i+1,:).*conj(Z_data(i+1,:)))...
    +sum(Z_data1(i+1,:).*conj(Z_data1(i+1,:))));
end
dc_m_sum(1,k)=sum(dc_m);
end
figure(3);
plot(dc_m_sum);
[a,b]=sort(dc_m_sum);
d= b(end);%d为接收信号符号开始处索引，包含循环前缀
signal_start_index=d+m-1;%将索引转换成发射引号索引


%% OFDM信号解调
%载波频偏纠正
Cfo_data1=[Rx_data(d-512:d-1),Rx_data(d-2048:d-1),Rx_data(d:L_Rx_data)];
Rx_Cfo_data1=cfo_correct(Cfo_data1);%利用循环前缀纠正载波频偏

Rx_Cfo_data11=reshape(Rx_Cfo_data1.',GI+IFFT_bin_length,[]).';
% 去掉循环前缀，取出OFDM符号传输的数据
Rx_data_complex_matrix=Rx_Cfo_data11(:,GI+1:GI+IFFT_bin_length);
% 求FFT，即OFDM信号解调
Y1=fft(Rx_data_complex_matrix)./IFFT_bin_length;
Rx_carriers=Y1(:,173:1877) ;
% 取出carriers序号对应的子载波上的发送数据，去掉加入的零
Rx_phase =angle(Rx_carriers);% 计算接收信号的相位特性
Rx_mag = abs(Rx_carriers);% 计算接收信号的幅度特性
[M, N]=pol2cart(Rx_phase, Rx_mag);%转换极坐标数据为直角坐标数据 
Rx_complex_carrier_matrix = complex(M, N);%两个直角坐标的实数据为构成复数据。
figure(3);
plot(Rx_complex_carrier_matrix,'*r');%画接收信号的星座图 
axis([-2, 2, -2, 2]);
title('接受信号数据星座图');
grid on

%4QAM解调
Rx_serial_complex_symbols = reshape(Rx_complex_carrier_matrix',...
size(Rx_complex_carrier_matrix, 1)*size(Rx_complex_carrier_matrix,2),1)';%将矩阵Rx_complex_carrier_matrix转换为1行的数组
Rx_decoded_binary_symbols=demoduqam4(Rx_serial_complex_symbols);%进行4QAM解调
baseband_in = Rx_decoded_binary_symbols;%将解调恢复的二进制信号存放在baseband_in

%误码率计算
bit_errors=find(baseband_in ~=baseband_out);

%解调恢复的二进制信号与发送二进制信号比较，查找误码
bit_error_count = size(bit_errors, 2); %计算误码个数
ber=bit_error_count/baseband_out_length;%计算误码率


