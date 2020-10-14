function hom_sens = sensitivity_imgs(hom_img, z_height)

%% Sensitivity field
J = calc_jacobian(hom_img);
hom_sens = rmfield(hom_img,'elem_data');

%% Fixed z_cross, varying measurement
slice_lvl = 0.1*z_height;
n_measurements = length(hom_sens.fwd_model.stimulation(1).meas_pattern(:,1));

figure
for inj_idx = 1:n_measurements
    hom_sens.elem_data = J(inj_idx,:);
    subplot(ceil(sqrt(n_measurements)),ceil(sqrt(n_measurements)),inj_idx);
    show_slices(hom_sens,[inf,inf,slice_lvl]) ;
end
sgtitle('Sensitivity field varying voltage pairs')

%% Fixed measurement, varying z_cross
fix_meas = 1;
n_plots = 16;

hom_sens.elem_data = J(fix_meas,:);

figure
for slice_lvl = (1/n_plots:1/n_plots:1)*z_height 
    subplot(ceil(sqrt(n_plots)),ceil(sqrt(n_plots)),round(n_plots*slice_lvl/z_height))
    show_slices(hom_sens,[inf,inf,slice_lvl]) 
end
sgtitle('Sensitivity field varying Z cross-section')

%% Fixed measurement, rotating xy_cross
x_zero = hom_sens.fwd_model.nodes(:,1);
y_zero = hom_sens.fwd_model.nodes(:,2);
n_rot = 16;

figure
for angle = 0:(2*pi)/n_rot:2*pi*(1-1/n_rot)
    %rotating nodes
    rot = [cos(angle) -sin(angle);sin(angle) cos(angle)];
    hom_sens.fwd_model.nodes(:,[1 2]) = [x_zero y_zero] * transp(rot);
    
    subplot(ceil(sqrt(n_rot)),ceil(sqrt(n_rot)),1 + round(n_rot*angle/(2*pi)))
    show_slices(hom_sens,[inf,0,inf]) 
end
sgtitle('Sensitivity field rotating the sample')

end