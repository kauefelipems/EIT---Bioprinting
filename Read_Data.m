UTOM_path = '/home/kauefelipems/EIT---Bioprinting/data/UTOM_FILES/';

reading = input('\n What do you want? (1) Read Image Data (2) Read Calibrated Image Data (3) Read Channels Data\n');
buffer_size = 1000;
n_commands = 208;

switch(reading)

    case 1
        header_size = 4;

        EXP_NAME = input('Name the Experiment:','s');

        HOM_File = [UTOM_path EXP_NAME '_HOM.txt'];
        INH_File = [UTOM_path EXP_NAME '_INH.txt'];
        
        read_hom = readmatrix(HOM_File);
        read_inh = readmatrix(INH_File);

        header_hom = read_hom(1:header_size);
        data_hom = read_hom(header_size+1:end);
        header_inh = read_inh(1:header_size);
        data_inh = read_inh(header_size+1:end);

        close all
        figure
        plot(data_hom);
        hold on
        plot(data_inh);

        hom_vector = zeros(1,n_commands);
        inh_vector = zeros(1,n_commands);
        
        harm_hom = 10^header_hom(4)*1e3*buffer_size/(header_hom(3)*1e6)+1;
        harm_ihn = 10^header_inh(4)*1e3*buffer_size/(header_inh(3)*1e6)+1;

        for i = 1:208
            x_value = (i-1)*buffer_size;
            dft_hom = 2*fft(data_hom(x_value+1:x_value+buffer_size));
            dft_ihn = 2*fft(data_inh((x_value+1:x_value+buffer_size)));
        
            hom_vector(i) = abs(dft_hom(harm_hom));
            inh_vector(i) = abs(dft_ihn(harm_ihn));
        end
        
        data_struct.hom = transpose(hom_vector)./max(hom_vector);
        data_struct.inh= transpose(inh_vector)./max(inh_vector);
        
        figure
        plot(data_struct.hom);
        hold on
        plot(data_struct.inh);

    case 2

        header_size = 4;

        EXP_NAME = input('Name the Experiment:','s');
        HOM_F1_File = [UTOM_path EXP_NAME '_F1_HOM.txt'];
        HOM_F2_File = [UTOM_path EXP_NAME '_F2_HOM.txt'];
        INH_F1_File = [UTOM_path EXP_NAME '_F1_INH.txt'];
        INH_F2_File = [UTOM_path EXP_NAME '_F2_INH.txt'];

        read_hom1 = readmatrix(HOM_F1_File);
        read_hom2= readmatrix(HOM_F2_File);
        read_inh1 = readmatrix(INH_F1_File);
        read_inh2 = readmatrix(INH_F2_File);

        header_hom1 = read_hom1(1:header_size);
        data_hom1 = read_hom1(header_size+1:end);
        header_hom2 = read_hom2(1:header_size);
        data_hom2 = read_hom2(header_size+1:end);

        header_inh1 = read_inh1(1:header_size);
        data_inh1 = read_inh1(header_size+1:end);
        header_inh2 = read_inh2(1:header_size);
        data_inh2 = read_inh2(header_size+1:end);

        close all
        figure
        plot(data_hom1);
        hold on
        plot(data_inh1);
        figure
        plot(data_hom2);
        hold on
        plot(data_inh2);

        calib_vector_1 = zeros(1,n_commands);
        calib_vector_2 = zeros(1,n_commands);
        
        harm_hom1 = 10^header_hom1(4)*buffer_size*1e3/(header_hom1(3)*1e6)+1;
        harm_hom2 = 10^header_hom2(4)*buffer_size*1e3/(header_hom2(3)*1e6)+1;
        harm_inh1 = 10^header_inh1(4)*buffer_size*1e3/(header_inh1(3)*1e6)+1;
        harm_inh2 = 10^header_inh2(4)*buffer_size*1e3/(header_inh2(3)*1e6)+1;

        for i = 1:208
            x_value = (i-1)*buffer_size;
            dft_hom1 = 2*fft(data_hom1(x_value+1:x_value+buffer_size));
            dft_hom2 = 2*fft(data_hom2(x_value+1:x_value+buffer_size));
            dft_ihn1 = 2*fft(data_inh1(x_value+1:x_value+buffer_size));
            dft_ihn2 = 2*fft(data_inh2(x_value+1:x_value+buffer_size));
      
            calib_vector_1(i) = abs(dft_ihn1(harm_inh1)) - abs(dft_hom1(harm_hom1));
            calib_vector_2(i) = abs(dft_ihn2(harm_inh2)) - abs(dft_hom2(harm_hom2));
        end
        
        data_struct.hom = transpose(calib_vector_1);
        data_struct.inh= transpose(calib_vector_2);
        
        figure
        plot(data_struct.hom);
        hold on
        plot(data_struct.inh);

    case 3

        header_size = 4;
        FILE_NAME = input('Name the File:','s');
        EIT_File = [UTOM_path FILE_NAME '.txt'];
        
        read_vector = readmatrix(EIT_File);
        header = read_vector(1:header_size);
        data = read_vector(header_size+1:end);

        close all
        figure
        plot(data);
        harm = 10^header(4)*buffer_size*1e3/(header(3)*1e6);
        harm_value = zeros(1,length(data)/buffer_size);
        data = data - mean(data);

        for i = 1:length(data)/buffer_size
            x_value = (i-1)*buffer_size;
            dft_hom1 = 2*fft(data(x_value+1:x_value+buffer_size));
            harm_value(i) = abs(dft_hom1(harm+1));
        end
        harm_value = harm_value/max(harm_value);
        figure
        plot(1:length(data)/buffer_size, harm_value);
end




