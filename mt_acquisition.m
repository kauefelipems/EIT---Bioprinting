%% Read the PSPICE output files 
file_name1 = '\\hom_spice_adad.csv';
file_name2 = '\\inh_spice_adad.csv';
pspice_output.homimg = READ_CURVES([pspice_output_path file_name1]);
pspice_output.inhomimg = READ_CURVES([pspice_output_path file_name2]);

%% Sample and process the measurement vector 
adc_1 = ADC_MODEL(1e6, 14, 10);

%Digitalize and average homogeneous data
homg_window = adc_1.packg(pspice_output.homimg, trigger);
homg_ideal_samp = adc_1.sample(homg_window);
homg_dig_sample = adc_1.discretize(homg_ideal_samp);
homg_data_norm = adc_1.avg_pp(homg_dig_sample,periods);

%Digitalize and average inhomogeneous data
inh_window = adc_1.packg(pspice_output.inhomimg, trigger);
inh_ideal_samp = adc_1.sample(inh_window);
inh_dig_sample = adc_1.discretize(inh_ideal_samp);
inh_data_norm = adc_1.avg_pp(inh_dig_sample,periods);


%% Reconstruct image 

% Create EIDORS measurement structures for PSPICE data
homg_expdata.meas = homg_data_norm;
homg_expdata.time = NaN;
homg_expdata.name = 'solved by fwd_solve_1st_order';
homg_expdata.type = 'data';

inh_expdata.meas = inh_data_norm;
inh_expdata.time = NaN;
inh_expdata.name = 'solved by fwd_solve_1st_order';
inh_expdata.type = 'data';

%These steps are application dependent.

