%% Setting file path folders

mydir = 'C:\\Users\\Kaue\\Documents\\MATLAB\\Master Thesis';

netlist_path = [mydir '\\NETLIST files'];
testbench_path = [mydir '\\TESTBENCH files'];
pspice_output_path = [mydir '\\PSPICE files'];

%% Simulate ideal phantom data
n_elec = 16;
freq = 10e3; %stimulation frequency
[fmdl1, fmdl2] = phantom_FEM(n_elec); %spheroid phantom (based on Wu et al., 2020)
[spher_cond, media_cond] = MFC7sp_cond(freq) % MCF-7 Spheroid Cell Model conductivity 
                                             %(based on Wu et al., 2020)
%Plotting models
show_fem(fmdl1);
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

% create homogeneous image + simulated data
hom_img = mk_image(fmdl2, media_cond); %use the same mesh of the inhomogeneous case
                                        % to avoid variations due to mesh geometry
inh_img = mk_image(fmdl2, media_cond); %media conductivity
inh_img.elem_data(fmdl2.mat_idx{1}) = spher_cond; %spheroid conductivity

% get internal voltages of the foward problem 
hom_img.fwd_solve.get_all_meas = 1;
inh_img.fwd_solve.get_all_meas = 1;

% solving ideal data set
hom_idealdata=fwd_solve(hom_img);
inh_idealdata=fwd_solve(inh_img); %ideal data from the foward solver
figure
plot(real(inh_idealdata.meas) - real(hom_idealdata.meas))
title('Real measurement difference')
figure
plot(imag(inh_idealdata.meas) - imag(hom_idealdata.meas))
title('Imaginary measurement difference')
%% Simulate differential foward potentials

[hom_img_v, diff_img_v] = potential_imgs(hom_img, inh_img, hom_idealdata, inh_idealdata, 7e-3);
hom_sens = sensitivity_imgs(hom_img, 7e-3);

%% Solve inverse problem

fmdl_inv = phantom_FEM_inv(n_elec);

%Plotting models
figure
show_fem(fmdl_inv);
title('FEM model for inverse problem')

%Setting stimulation for homogeneous phantom
fmdl_inv.stimulation = stim;
fmdl_inv.solve=      'fwd_solve_1st_order';
fmdl_inv.system_mat= 'system_mat_1st_order';
fmdl_inv.jacobian = 'jacobian_adjoint'; %for sensitivity matrix

% Create inverse model
clear inv3d;
inv3d.name = 'EIT inverse';
inv3d.solve = 'inv_solve_diff_GN_one_step';
inv3d.hyperparameter.value = 3e-3;
inv3d.inv_solve_diff_GN_one_step.calc_step_size = 1;

inv3d.R_prior= 'prior_TV';
inv3d.reconst_type= 'difference';
inv3d.jacobian_bkgnd.value= media_cond;
inv3d.fwd_model= fmdl_inv;
inv3d.fwd_model.misc.perm_sym= '{y}';
inv3d= eidors_obj('inv_model', inv3d); %caching the inverse model

% Reconstruct ideal image
ideal_img= inv_solve( inv3d, hom_idealdata, inh_idealdata);
error = calc_solution_error(ideal_img, inv3d, hom_idealdata, inh_idealdata);

%% Plotting 

n_plots = 16;
z_height = 7e-3;

%Calculated Image (z_cross)
figure
for slice_lvl = (1/n_plots:1/n_plots:1)*z_height 
    subplot(floor(sqrt(n_plots)),ceil(sqrt(n_plots)),round(n_plots*slice_lvl/z_height))
    show_slices(ideal_img,[inf,inf,slice_lvl]) 
end
sgtitle('Z cross-sectional Calculated Image')

%Calculated Image (rotating)
x_zero = ideal_img.fwd_model.nodes(:,1);
y_zero = ideal_img.fwd_model.nodes(:,2);
n_rot = 16;

figure
for angle = 0:(2*pi)/n_rot:2*pi*(1-1/n_rot)
    rot = [cos(angle) -sin(angle);sin(angle) cos(angle)]; %rotating nodes
    ideal_img.fwd_model.nodes(:,[1 2]) = [x_zero y_zero] * transp(rot);
    
    subplot(ceil(sqrt(n_rot)),ceil(sqrt(n_rot)),1 + round(n_rot*angle/(2*pi)))
    show_slices(ideal_img,[inf,0,inf]) 
end
sgtitle('Rotated Calculated Image')

%Real Image (z_cross)
figure 
for slice_lvl = (1/n_plots:1/n_plots:1)*z_height 
    subplot(floor(sqrt(n_plots)),ceil(sqrt(n_plots)),round(n_plots*slice_lvl/z_height))
    show_slices(inh_img,[inf,inf,slice_lvl]) 
end
sgtitle('Z cross-sectional Ideal Image')

%Real Image (rotating)
x_zero = inh_img.fwd_model.nodes(:,1);
y_zero = inh_img.fwd_model.nodes(:,2);
n_rot = 16;

figure
for angle = 0:(2*pi)/n_rot:2*pi*(1-1/n_rot)
    rot = [cos(angle) -sin(angle);sin(angle) cos(angle)]; %rotating nodes
    inh_img.fwd_model.nodes(:,[1 2]) = [x_zero y_zero] * transp(rot);
    
    subplot(ceil(sqrt(n_rot)),ceil(sqrt(n_rot)),1 + round(n_rot*angle/(2*pi)))
    show_slices(inh_img,[inf,0,inf]) 
end
sgtitle('Rotated Ideal Image')