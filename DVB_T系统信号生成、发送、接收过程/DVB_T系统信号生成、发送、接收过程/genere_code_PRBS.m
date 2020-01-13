function seq_PRBS=genere_code_PRBS()

seq_PRBS=[1 1 1 1 1 1 1 1 1 1 1];

for k=12:8192
    seq_PRBS(k)=xor(seq_PRBS(k-9),seq_PRBS(k-11));
end

seq_PRBS = -seq_PRBS*2+1;

end