data = readmatrix('/home/kauefelipems/EIT---Bioprinting/data/UTOM_FILES/UTOM_EIT_Data.txt');
data2 = readmatrix('/home/kauefelipems/EIT---Bioprinting/data/UTOM_FILES/UTOM_EIT_Data2.txt');

output_data = zeros(1,(length(data))/2);
output_data2 = zeros(1,(length(data2))/2);

%Build uint16_t data from uint8_t
for i = 1 : (length(data))/2
    output_data(i) = uint16(data(2*i - 1) + bitshift(data(2*i),8));
    output_data2(i) = uint16(data(2*i - 1) + bitshift(data2(2*i),8));
end

close all
figure
plot(output_data);
hold on
plot(output_data2);

treated_data = zeros(1,208);
treated_data2 = zeros(1,208);

for i = 1:208
    x_value = (i-1)*1024;
    dft_value1 = 2*fft(output_data(x_value+1:x_value+1024));
    dft_value2 = 2*fft(output_data2((x_value+1:x_value+1024)));

    treated_data(i) = abs(dft_value1(6));
    treated_data2(i) = abs(dft_value2(6));
end


data_struct.hom = transpose(treated_data./max(treated_data2));
data_struct.inh= transpose(treated_data2./max(treated_data2));

figure
plot(data_struct.hom);
hold on
plot(data_struct.inh);