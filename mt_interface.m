%% Test script to collect EIT data from μ-TOM

UTOM_path = 'C:\\Users\\DELL\\Documents\\MATLAB\\Master Thesis\\UTOM_FILES';

%% Measurement Definitions

%Port Communication
port = "COM5";
baudrate = 115200;
n_commands = length(stimulation_pattern);
data_bits = 8;
stop_bits = 1;
parity = "Odd";

%Measurement Vector
buff_size = 1000;

%Switching_Stage
stimulation_pattern = csvread([UTOM_path '\\UTOM_SW.txt']);

%PGA
gain_max = 127;
gain = gain_max*ones(n_commands,1);
gain_mode = "fixed";

%Excitation
freq_in = 10e3;
n_periods = 5;
time_meas = n_periods/freq_in;

%% Opening serial connection with the device

utom = serialport(port, baudrate); 

%% EIT Measurements Loop

%Configure callback function to read data
configureCallback(s,"bytes", buff_size, @uTOM_DataSerialCallback)

%Communication variables
global serial_data;
global ready_flag;
global count;

ready_flag = 1;
count = 1;
serial_data = zeros(n_commands);

while(count <= n_commands)
    
    if(ready_flag == 1)
        if (gain_mode == "fixed")                           
            if (count == 1)
                command = [uint8('G'), gain_max, 0, 0, 0]; %Set gain only one time
                write(utom, command, "uint8"); 
            end
        else
            command = [uint8('G'), gain(count), 0, 0, 0]; %Change gain for every channel
            write(utom, command, "uint8"); 
        end
        
        command = [uint8('S'), stimulation_pattern(count,:)]; %Set new channel
        write(utom, command, "uint8");
        command = [uint8('M'), 0, 0, 0, 0];                   %Measure
        write(utom, command, "uint8");
        
        count = count + 1;
        ready_flag = 0;
    end
    
end

%% End of Communication
utom.Port = [];

%% Dumping EIT Vector to File

%Build uint16_t data from uint8_t
for i = 1 : buff_size/2
    output_data = serial_data(2*i - 1) + bitshift(serial_data(2*i),8);
end

%Load values to output file
EIT_File = [UTOM_path '\\UTOM_EIT_Data.txt'];
writematrix(output_data, EIT_File)

%Plot EIT Vector
figure
plot(output_data)
