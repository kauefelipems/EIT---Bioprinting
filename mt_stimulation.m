%% Setting file path folders

mydir = 'C:\\Users\\Kaue\\Documents\\MATLAB\\Master Thesis';

netlist_path = [mydir '\\NETLIST files'];
testbench_path = [mydir '\\TESTBENCH files'];
pspice_output_path = [mydir '\\PSPICE files'];

%% Simulate ideal phantom data

run(which('phantom_FEM')) %%run phantom

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
hom_img = mk_image( fmdl1, media_cond); 
inh_img = mk_image( fmdl2, media_cond); %media conductivity
inh_img.elem_data(fmdl2.mat_idx{1}) = spher_cond; %spheroid conductivity

% get internal voltages of the foward problem 
hom_img.fwd_solve.get_all_meas = 1;
inh_img.fwd_solve.get_all_meas = 1;

% solving ideal data set
hom_idealdata=fwd_solve(hom_img);
inh_idealdata=fwd_solve(inh_img); %ideal data from the foward solver
figure
plot(hom_idealdata.meas-inh_idealdata.meas)

%% Simulate differential foward potentials

%run(which('potential_imgs')) %%run phantom
%run(which('sensitivity_imgs')) %%run phantom

%% Solve inverse problem

run(which('phantom_FEM_inv')) %coard matrix for the inverse
                        
%Setting stimulation for homogeneous phantom
fmdl_inv.stimulation = stim;
fmdl_inv.solve=      'fwd_solve_1st_order';
fmdl_inv.system_mat= 'system_mat_1st_order';
fmdl_inv.jacobian = 'jacobian_adjoint'; %for sensitivity matrix

% Create inverse model
clear inv3d;
inv3d.name= 'EIT inverse';
inv3d.solve=       'inv_solve_diff_GN_one_step';
inv3d.hyperparameter.value = 3e-3;

inv3d.R_prior= 'prior_TV';
inv3d.reconst_type= 'difference';
inv3d.jacobian_bkgnd.value= 1;
inv3d.fwd_model= fmdl_inv;
inv3d.fwd_model.misc.perm_sym= '{y}';
inv3d= eidors_obj('inv_model', inv3d);

% Reconstruct and show ideal image
ideal_img= inv_solve( inv3d, inh_idealdata, hom_idealdata);

n_plots = 16;

%Calculated Image
figure
for slice_lvl = (1/n_plots:1/n_plots:1)*height 
    subplot(floor(sqrt(n_plots)),ceil(sqrt(n_plots)),round(n_plots*slice_lvl/height))
    show_slices(ideal_img,[inf,inf,slice_lvl]) 
end

%Real Image
figure 
for slice_lvl = (1/n_plots:1/n_plots:1)*height 
    subplot(floor(sqrt(n_plots)),ceil(sqrt(n_plots)),round(n_plots*slice_lvl/height))
    show_slices(inh_img,[inf,inf,slice_lvl]) 
end