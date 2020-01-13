%4QAM调制子程序 
function [complex_qam_data]=qam4(bitdata)
X1=reshape(bitdata,2,length(bitdata)/2)' ;
d=1;
for i=1:length(bitdata)/2;
    for j=1:2
        X1(i,j)=X1(i,j)*(2^(2-j)); 
    end
    source(i,1)=1+sum(X1(i,:)); 
end
mapping=[-1*d 1*d;d  d;-1*d -1*d;1*d  -1*d];
for i=1:length(bitdata)/2
    qam_data(i,:)=mapping(source(i),:);
end
     complex_qam_data=complex(qam_data(:,1),qam_data(:,2));