carrier_count=1705;%number of subcarriers
 symbols_per_carrier=68;
 bits_per_symbol=2;
 IFFT_bin_length=2048;%FFT����
 PrefixRatio=1/4; 
 GI=PrefixRatio*IFFT_bin_length ;
%  Data generator (A)
 baseband_out_length = carrier_count* symbols_per_carrier* bits_per_symbol;%����������bit��
 rng('default');
 baseband_out=round(rand(1,baseband_out_length));%������Ķ�����bit��
%  4QAM���Ʋ���������ͼ
complex_carrier_matrix=qam4(baseband_out);%��baseband_out�еĶ����Ʊ�������ÿ2����ת��Ϊһ��4QAM�ź�
complex_carrier_matrix=reshape(complex_carrier_matrix',carrier_count,symbols_per_carrier)';
figure(1);  
plot(complex_carrier_matrix,'*r'); 
axis([-2, 2, -2, 2]);
title('4QAM���ƺ�����ͼ');
grid on

%�����ɢ��Ƶ
scatter_pilot=add_scattered(complex_carrier_matrix);

%���������Ƶ
continue_pilot=add_continue(scatter_pilot);

% OFDM���Ƽ�IFFT����
IFFT_modulation=[zeros(68,172) continue_pilot zeros(68,171)];
signal_after_IFFT= IFFT_bin_length.*ifft(IFFT_modulation);

%���ѭ��ǰ׺
XX=zeros(symbols_per_carrier,IFFT_bin_length+GI);
for k=1:symbols_per_carrier;
        for i=1:IFFT_bin_length;
            XX(k,i+GI)=signal_after_IFFT(k,i);
        end
        for i=1:GI;
            XX(k,i)=signal_after_IFFT(k,i+IFFT_bin_length-GI);%���ѭ��ǰ׺
        end
        
end
time_wave_matrix_cp=XX;%��ѭ��ǰ׺OFDM���š�
figure(2);
plot(0:length(time_wave_matrix_cp)-1,real(time_wave_matrix_cp(2,:)));%����ѭ��ǰ׺��ʱ���� 
grid on;
ylabel('Amplitude');
xlabel('Time');
title('OFDM Time Signal with CP, One Symbol Period');

%�ӳ�ʼ��λ
w=0.01;
time_wave_matrix_cp1=time_wave_matrix_cp.* exp(1i*2*pi*w);

%������
SNR=50;
time_wave_matrix_cp2=noise(time_wave_matrix_cp1,SNR);

%���ɷ����źţ������任
Tx_data=reshape(time_wave_matrix_cp2', (symbols_per_carrier)*(IFFT_bin_length+GI),1)';

% �ز�Ƶƫ
long=length(Tx_data);
cita=1e-03;
Cfo_data=Tx_data .*exp(-1i*2*pi*cita*(1:long)/ IFFT_bin_length);%��������½��յ�������


%%  �����Ȼ����
%����rou
Cfo_data1=reshape(Cfo_data.',[],symbols_per_carrier).';
signal_noise=[Cfo_data1(:,513:684),Cfo_data1(:,2390:2560)];
signal_noise1=reshape(signal_noise.',[],1).';
E_signal_noise=sum(signal_noise1.*conj(signal_noise1))/343;%��������������
location=[1,49,55,88,142,157,193,202,256,280,283,334,433,451,484,526,...
    531,619,637,715,760,766,781,805,874,889,919,940,943,970,985,1051,1102,...
    1108,1111,1138,1141,1147,1207,1270,1324,1378,1492,1684,1705];
LL=length(location);
signal_sum=Cfo_data1(:,684+location);
signal_sum1=reshape(signal_sum.',[],1).';
E_signal_sum=sum(signal_sum1.*conj(signal_sum1))/LL;%��������+�źŵ�����
E_signal=E_signal_sum-E_signal_noise;%�����źŵ�����
rou=1/(1+E_signal_noise/E_signal);

dc_m_sum=zeros(1,2560);%����һ�����ų���
m=300;  %��������ź���Է����źŵĳ�ʼλ��
Rx_data=Cfo_data(m:174080);%�����ź�
L_Rx_data=length(Rx_data);
for k=1:2560%����һ�����ų���
 Z_data=zeros(10,512);
 Z_data1=zeros(10,512);
 dc_m=zeros(10,1);
for i= 0:9 %ȡ10�����Ž������
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
d= b(end);%dΪ�����źŷ��ſ�ʼ������������ѭ��ǰ׺
signal_start_index=d+m-1;%������ת���ɷ�����������


%% OFDM�źŽ��
%�ز�Ƶƫ����
Cfo_data1=[Rx_data(d-512:d-1),Rx_data(d-2048:d-1),Rx_data(d:L_Rx_data)];
Rx_Cfo_data1=cfo_correct(Cfo_data1);%����ѭ��ǰ׺�����ز�Ƶƫ

Rx_Cfo_data11=reshape(Rx_Cfo_data1.',GI+IFFT_bin_length,[]).';
% ȥ��ѭ��ǰ׺��ȡ��OFDM���Ŵ��������
Rx_data_complex_matrix=Rx_Cfo_data11(:,GI+1:GI+IFFT_bin_length);
% ��FFT����OFDM�źŽ��
Y1=fft(Rx_data_complex_matrix)./IFFT_bin_length;
Rx_carriers=Y1(:,173:1877) ;
% ȡ��carriers��Ŷ�Ӧ�����ز��ϵķ������ݣ�ȥ���������
Rx_phase =angle(Rx_carriers);% ��������źŵ���λ����
Rx_mag = abs(Rx_carriers);% ��������źŵķ�������
[M, N]=pol2cart(Rx_phase, Rx_mag);%ת������������Ϊֱ���������� 
Rx_complex_carrier_matrix = complex(M, N);%����ֱ�������ʵ����Ϊ���ɸ����ݡ�
figure(3);
plot(Rx_complex_carrier_matrix,'*r');%�������źŵ�����ͼ 
axis([-2, 2, -2, 2]);
title('�����ź���������ͼ');
grid on

%4QAM���
Rx_serial_complex_symbols = reshape(Rx_complex_carrier_matrix',...
size(Rx_complex_carrier_matrix, 1)*size(Rx_complex_carrier_matrix,2),1)';%������Rx_complex_carrier_matrixת��Ϊ1�е�����
Rx_decoded_binary_symbols=demoduqam4(Rx_serial_complex_symbols);%����4QAM���
baseband_in = Rx_decoded_binary_symbols;%������ָ��Ķ������źŴ����baseband_in

%�����ʼ���
bit_errors=find(baseband_in ~=baseband_out);

%����ָ��Ķ������ź��뷢�Ͷ������źűȽϣ���������
bit_error_count = size(bit_errors, 2); %�����������
ber=bit_error_count/baseband_out_length;%����������


