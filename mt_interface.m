%% Test script to collect EIT data from μ-TOM

UTOM_path = '/home/kauefelipems/EIT---Bioprinting/data/UTOM_FILES';
EIT_File = [UTOM_path '/UTOM_EIT_Data13.txt'];
writematrix([], EIT_File);
clear utom

%% Measurement Definitions

%Switching_Stages
stimulation_pattern = csvread([UTOM_path '/UTOM_SW.txt']);

%Port Communication
port = "/dev/ttyACM0";
baudrate = 115200;
n_commands = length(stimulation_pattern);
data_bits = 8;
stop_bits = 1;
parity = "Odd";

%Measurement Vector
buff_size = 1000;


%PGA
gain_max = 1;
gain = gain_max*ones(n_commands,1);
gain_mode = "fixed";

%Excitation
freq_in = 10e3;
n_periods = 5;
time_meas = n_periods/freq_in;

%% Opening serial connection with the device

utom = serialport(port, baudrate, 'DataBits',data_bits,'Parity',parity,'StopBits',stop_bits,"Timeout",60); 
%% EIT Measurements Loop

%Configure callback function to read data
%configureCallback(utom,"terminator", @uTOM_DataSerialCallback)
%configureTerminator(utom,"CR/LF")

writematrix([], EIT_File);

command = [uint8('P'), 0, 0, 0, 0]; %Write protocol mode
write(utom, command, "uint8");

for count = 1:n_commands
    command = gain(count); %Set new channel
    write(utom, command, "uint8"); 
    command = stimulation_pattern(count,:);                   %Measure
    write(utom, command, "uint8");
end

command = [uint8('E'), 1, 0, 0, 0]; %Set new channel
write(utom, command, "uint8");

command = [uint8('R'), 0, 0, 0, 0]; %Set new channel
write(utom, command, "uint8");

tic
data = read(utom,2*208*1024,"uint8");
toc

char_string = char(data);
data16 = uint16(char_string);
writematrix(data16, EIT_File);

%% End of Communication


