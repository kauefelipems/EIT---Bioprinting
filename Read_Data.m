data = readmatrix('/home/kauefelipems/EIT---Bioprinting/data/UTOM_FILES/UTOM_EIT_Data.txt');

output_data = zeros(1,(length(data))/2);

%Build uint16_t data from uint8_t
for i = 1 : (length(data))/2
    output_data(i) = uint16(data(2*i - 1) + bitshift(data(2*i),8));
end

plot(output_data);