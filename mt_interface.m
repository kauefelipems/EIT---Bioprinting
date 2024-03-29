%% Test script to collect EIT data from μ-TOM

UTOM_path = '/home/kauefelipems/EIT---Bioprinting/data/UTOM_FILES/';

experiment = input('\n What do you want? (1) Run Protocol (2) Test Channel (3) Test Channels\n');

FILE_NAME = input('Name the File:','s');
EIT_File = [UTOM_path FILE_NAME '.txt'];
writematrix([], EIT_File);
clear utom

%Port Communication
port = "/dev/ttyACM0";
baudrate = 115200;
buffer_size = 1000;
data_bits = 8;
stop_bits = 1;
parity = "Odd";
uart_delay = 5/1000;

%frequency
fs = 2e6;

%PGA
gain_max = input('\n Please insert the gain\n');

%Excitation
freq_sel = input('\n What frequency? (1) 10 kHz (2) 100 kHz\n');

switch(freq_sel)
    case 1
        freq = 1e4;
    case 2 
        freq = 1e5;
end

%% Opening serial connection with the device

utom = serialport(port, baudrate, 'DataBits',data_bits,'Parity',parity,'StopBits',stop_bits,"Timeout",60); 

%% Measurement Definitions

switch (experiment)

    case 1

        %Protocol Commands
        stimulation_pattern = csvread([UTOM_path '/UTOM_SW.txt']);
        n_commands = length(stimulation_pattern);
        n_bytes = 2*buffer_size*n_commands;
    
        %% EIT Measurements
                  
        %Header to the File
        HEADER = [uint8('P'), gain_max, fs/1e6, freq_sel]; %MODE, GAIN, SAMPLING FREQUENCY, SIGNAL FREQUENCY

        command = [uint8('P'), 0, 0, 0, 0]; %Write protocol mode
        write(utom, command, "uint8");
        pause(uart_delay);

        for count = 1:n_commands
            command = gain_max; %Set new channel
            write(utom, command, "uint8"); 
            pause(uart_delay);
            command = stimulation_pattern(count,:);                   %Measure
            write(utom, command, "uint8");
            pause(uart_delay);
        end
        
        command = [uint8('E'), freq_sel, 0, 0, 0]; %Set new channel
        write(utom, command, "uint8");
        pause(uart_delay);
        command = [uint8('R'), 0, 0, 0, 0]; %Set new channel
        write(utom, command, "uint8");
        
        tic
        data = read(utom,n_bytes,"uint8");
        toc

    case 2

        n_bytes = 2*buffer_size;

        channel = input('\n What channel?\n');

        %Header to the File
        HEADER = [uint8('C'), gain_max, fs/1e6, freq_sel]; %MODE, GAIN, FREQUENCY

        command = [uint8('E'), freq_sel, 0, 0, 0]; %Set new channel
        write(utom, command, "uint8");
        pause(uart_delay);
        command = [uint8('G'), gain_max, 0, 0, 0]; %Set new channel
        write(utom, command, "uint8");    
        pause(uart_delay);
        command = [uint8('S'), channel]; %Set new channel
        write(utom, command, "uint8");    
        pause(uart_delay);
        command = [uint8('M'), 0, 0, 0, 0]; %Set new channel
        write(utom, command, "uint8");    

        tic
        data = read(utom,n_bytes,"uint8");
        toc

    case 3

        stimulation_pattern = csvread([UTOM_path '/CHANNELS_SW.txt']);
        n_commands = length(stimulation_pattern);
        n_bytes = 2*buffer_size;
        data = zeros(1,n_bytes*n_commands);

        command = [uint8('E'), freq_sel, 0, 0, 0]; %Set new channel
        write(utom, command, "uint8");
        pause(uart_delay);
        command = [uint8('G'), gain_max, 0, 0, 0]; %Set new channel
        write(utom, command, "uint8");    
        pause(uart_delay);

        for i = 1:n_commands
            
            channel = stimulation_pattern(i,:);
    
            %Header to the File
            HEADER = [uint8('C'), gain_max, fs/1e6, freq_sel]; %MODE, GAIN, FREQUENCY
    
            command = [uint8('S'), channel]; %Set new channel
            write(utom, command, "uint8");    
            pause(uart_delay);
            command = [uint8('M'), 0, 0, 0, 0]; %Set new channel
            write(utom, command, "uint8");    
    
            tic
            data(1+(i-1)*n_bytes:i*n_bytes) = read(utom,n_bytes,"uint8");
            toc
        end

end

%% End of Communication and Data Collection

%Collects data
data = uint16(data);
output_data = zeros(1,(length(data))/2);

%Build uint16_t data from uint8_t
for i = 1 : (length(data))/2
    output_data(i) = uint16(data(2*i - 1) + bitshift(data(2*i),8));
end

%Load to File
writematrix([uint16(HEADER) output_data], EIT_File);

%Frees serialport 
clear utom;
