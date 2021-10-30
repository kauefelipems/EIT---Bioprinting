UTOM_path = '/home/kauefelipems/EIT---Bioprinting/data/UTOM_FILES/';

reading = input('\n What do you want? (1) Read Image Data (2) Read Channel Data\n');

switch(reading)

    case 1
        header_size = 3;

        FILE_NAME = input('Name the First File:','s');
        EIT_File = [UTOM_path FILE_NAME '.txt'];
        FILE_NAME2 = input('Name the Second File:','s');
        EIT_File2 = [UTOM_path FILE_NAME2 '.txt'];
        
        read = readmatrix(EIT_File);
        
        read2 = readmatrix(EIT_File2);

        header = read(1:header_size);
        data = read(header_size+1:end);
        header2 = read(1:header_size);
        data2 = read(header_size+1:end);

        close all
        figure
        plot(data);
        hold on
        plot(data2);

        treated_data = zeros(1,n_commands);
        treated_data2 = zeros(1,n_commands);
        
        for i = 1:208
            x_value = (i-1)*buffer_size;
            dft_value1 = 2*fft(data(x_value+1:x_value+buffer_size));
            dft_value2 = 2*fft(data2((x_value+1:x_value+buffer_size)));
        
            treated_data(i) = abs(dft_value1(6));
            treated_data2(i) = abs(dft_value2(6));
        end
        
        
        data_struct.hom = transpose(treated_data);
        data_struct.inh= transpose(treated_data2);
        
        figure
        plot(data_struct.hom);
        hold on
        plot(data_struct.inh);

    case 2

        header_size = 7;
        FILE_NAME = input('Name the File:','s');
        EIT_File = [UTOM_path FILE_NAME '.txt'];
        
        read = readmatrix(EIT_File);
        header = read(1:header_size);
        data = read(header_size+1:end);

        close all
        figure
        plot(data);
        
        dft_value1 = 2*fft(data);
        treated_data = abs(dft_value1(1:length(dft_value1)/2));
        
        data_struct.hom = transpose(treated_data);
        figure
        plot(data_struct.hom);
end




