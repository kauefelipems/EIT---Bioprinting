%% Create phantom data
netlist_path = 'C:\\Users\\DELL\\Documents\\MATLAB\\Master Thesis\\samples';

n_elec = 16;
fsignal = 10e3; %stimulation frequency
[fmdl1, fmdl2] = phantom_FEM(n_elec); %spheroid phantom (based on Wu et al., 2020)
[spher_cond, media_cond] = MFC7sp_cond(fsignal); % MCF-7 Spheroid Cell Model conductivity 
                                                 %(based on Wu et al., 2020)
%Plotting models
show_fem(fmdl2);
title('Homogeneous Phantom')
figure
show_fem(fmdl2);
title('Inhomogeneous Phantom')

%Stimulus settings
amp_ideal = 0.5e-3;
options = {'no_meas_current','no_rotate_meas'};
stim = mk_stim_patterns(n_elec, 1, '{ad}','{ad}', ...
                options, amp_ideal); %stimulation structure
                        
%Setting stimulation for homogeneous phantom
fmdl1.stimulation = stim;
fmdl1.solve=      'fwd_solve_1st_order';
fmdl1.system_mat= 'system_mat_1st_order';
fmdl1.jacobian = 'jacobian_adjoint'; %for sensitivity matrix

%Setting stimulation for inhomogeneous phantom
fmdl2.stimulation = stim;
fmdl2.solve=      'fwd_solve_1st_order';
fmdl2.system_mat= 'system_mat_1st_order';
fmdl2.jacobian = 'jacobian_adjoint'; %for sensitivity matrix

% create images
hom_img = mk_image(fmdl2, media_cond); %use the same mesh of the inhomogeneous case
                                        % to avoid variations caused by mesh geometry
inh_img = mk_image(fmdl2, media_cond); %media conductivity
inh_img.elem_data(fmdl2.mat_idx{1}) = spher_cond; %spheroid conductivity

%% Create PSPICE netlist

% Adding ground electrode from the images
hom_img.fwd_model.electrode(17).nodes = hom_img.fwd_model.gnd_node;
hom_img.fwd_model.electrode(17).z_contact = hom_img.fwd_model.electrode(16).z_contact;
inh_img.fwd_model.electrode(17).nodes = hom_img.fwd_model.gnd_node;
inh_img.fwd_model.electrode(17).z_contact = hom_img.fwd_model.electrode(16).z_contact;

% % Generating netlist files
% eit_pspice(hom_img, [netlist_path '\\sp_hom']);
% eit_pspice(inh_img, [netlist_path '\\sp_inh']);
% 
% % Removing ground electrode from the images
% hom_img.fwd_model.electrode = hom_img.fwd_model.electrode(1:end-1); 
% inh_img.fwd_model.electrode = inh_img.fwd_model.electrode(1:end-1); 