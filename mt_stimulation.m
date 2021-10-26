%% Set stimulation signal file for simulations and experiments with μ-TOM

% Create path_list for stimualtion files
path_list = {};
testbench_path = '/home/kauefelipems/EIT---Bioprinting/data/stimulus';
UTOM_path = '/home/kauefelipems/EIT---Bioprinting/data/UTOM_FILES';

% Signal parameters (f = fsignal)
v_amp = 1.65;
periods = 2;

% DAC parameters
fs = 1e6;
n_bits = 12;
full_scale = 3.3;

%Generate DAC sampled sine wave 
dac_1 = DAC_MODEL(fs, n_bits, full_scale);
sine_wave = dac_1.sine(fsignal, v_amp, periods);

%Create stimulus file for PWL source
stimulus_file = [testbench_path '/DA_output.txt'];
path_list = [path_list, stimulus_file];
pwl_write(stimulus_file, sine_wave.time, sine_wave.amp)

%% Set multiplexing patterning files 

%Multiplexer parameters
mux_on = 5;
mux_off = 0;
tsampling = periods/fsignal;
tinj = 100e-6;
tmeas = 50e-6;
tinit = 3000e-6;

%Instancing control objects
mux_1 = MUX_CONTROL(mux_on, mux_off, tsampling, tinj, tmeas, tinit);

%Generating control PWL vector and sampling trigger for the ADC
[mux, trigger] = mux_1.pwl_gen(hom_img.fwd_model);

%Build mux PWL strings
for i = 1:ceil(log2(n_elec))
    
    MUX_IP_file = [testbench_path '/MUX_IP_' int2str(i) '.txt'];
    MUX_IM_file = [testbench_path '/MUX_IM_' int2str(i) '.txt'];
    MUX_MP_file = [testbench_path '/MUX_MP_' int2str(i) '.txt'];
    MUX_MM_file = [testbench_path '/MUX_MM_' int2str(i) '.txt'];

    path_list = [path_list, MUX_IP_file, MUX_IM_file, MUX_MP_file, MUX_MM_file];
    
    pwl_write(MUX_IP_file, mux.time(1:end-1), mux.ip(:,i));
    pwl_write(MUX_IM_file, mux.time(1:end-1), mux.im(:,i));
    pwl_write(MUX_MP_file, mux.time(1:end-1), mux.mp(:,i));
    pwl_write(MUX_MM_file, mux.time(1:end-1), mux.mm(:,i));
end

%Generate command matrix for the μ-TOM interface 
switch_matrix = sw_commands(hom_img.fwd_model);

%% Create file with PWL paths 

% The PWL_paths lists all PWL stimulus paths to facilitate the manual
% source assignment on PSPICE 
PWL_paths = [testbench_path '/PWL_paths.txt'];
FILE = fopen(PWL_paths, 'wt');
for i=1:length(path_list)
    fprintf(FILE,[path_list{i} '\n']);
end
fclose(FILE);
eidors_msg(['saved PATHS to ' PWL_paths]);

%% Create output file for the μ-TOM interface switching manager

switching_file = [UTOM_path '/UTOM_SW.txt'];
writematrix(switch_matrix, switching_file)
