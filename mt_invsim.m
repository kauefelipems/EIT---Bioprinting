%% Solve inverse problem
fmdl_inv = phantom_FEM(n_elec);

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
hom_idealdata = homg_expdata.meas;
inh_idealdata = inh_expdata.meas;
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