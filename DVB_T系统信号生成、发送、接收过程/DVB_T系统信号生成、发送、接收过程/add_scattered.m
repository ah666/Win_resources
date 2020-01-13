function scatter_pilot=add_scattered(complex_carrier_matrix)
seq_PRBS=genere_code_PRBS();
a=zeros(4,142);
for l=1:4
   for p=0:141
    a(l,p+1)=12*p+3*(l-1)+1;
    complex_carrier_matrix(l,a(l,p+1))=seq_PRBS(p+1)*4/3;
    end
end
  complex_carrier_matrix(1,1705)=seq_PRBS(143)*4/3;
  scatter_pilot=[];
for i=1:17
    scatter_pilot=[scatter_pilot;complex_carrier_matrix(1:4,:)];
end
end