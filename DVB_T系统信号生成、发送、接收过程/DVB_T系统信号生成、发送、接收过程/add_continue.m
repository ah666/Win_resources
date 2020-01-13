function continue_pilot=add_continue(scatter_pilot)
seq_PRBS=genere_code_PRBS();
continue_seq=seq_PRBS(1:45)*4/3;
continue_seq1=ones(68,1)*continue_seq;
location=[1,49,55,88,142,157,193,202,256,280,283,334,433,451,484,526,...
    531,619,637,715,760,766,781,805,874,889,919,940,943,970,985,1051,1102,...
    1108,1111,1138,1141,1147,1207,1270,1324,1378,1492,1684,1705];
scatter_pilot(:,location(:))=continue_seq1;
  continue_pilot=scatter_pilot;
  
end