function [demodu_bit_symble]=demoduqam16(Rx_serial_complex_symbols)
complex_symbols=reshape(Rx_serial_complex_symbols,length(Rx_serial_complex_symbols),1);
d=1;
mapping=[-1*d 1*d;d  d;-1*d -1*d;1*d  -1*d];
complex_mapping=complex(mapping(:,1),mapping(:,2));
for i=1:length(Rx_serial_complex_symbols);
    for j=1:4;
        metrics(j)=abs(complex_symbols(i,1)-complex_mapping(j,1));
    end
    [min_metric  decode_symble(i)]= min(metrics) ;
end
decode_bit_symble=de2bi((decode_symble-1)','left-msb');
demodu_bit_symble=reshape(decode_bit_symble',1,length(Rx_serial_complex_symbols)*2);

end

