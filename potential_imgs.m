function [hom_img_v, diff_img_v] = potential_imgs(hom_img, inh_img, hom_idealdata, inh_idealdata, z_height)

%% Image structures
hom_img_v = rmfield(hom_img,'elem_data');
diff_img_v = rmfield(inh_img,'elem_data');
inh_img_g = inh_img; %for reference

%% Fixed z_cross, varying injection
n_injections = length(hom_img_v.fwd_model.stimulation);
slice_lvl = z_height*0.1;

%% Fixed injection, varying z_cross
fix_inj = 13;
diff_img_v.node_data = inh_idealdata.volt(:,fix_inj)-hom_idealdata.volt(:,fix_inj); 
n_plots = 16;

%% Fixed injection, rotating xy_cross
x_zero = hom_img_v.fwd_model.nodes(:,1);
y_zero = hom_img_v.fwd_model.nodes(:,2);
n_rot = 16;

%% PLOTS: Fixed z_cross, varying injection

figure
for inj_idx = 1:n_injections %solving for every injection    
    %homogeneous absolute potential
    hom_img_v.node_data = hom_idealdata.volt(:,inj_idx); %replace conductivity values with node voltage values

    subplot(ceil(sqrt(n_injections)),ceil(sqrt(n_injections)),inj_idx)
    show_slices(hom_img_v,[inf,inf,slice_lvl])
end
sgtitle('Potential distribution varying current electrodes (Homogeneous)')

figure
for inj_idx = 1:n_injections %solving for every injection    
    %differential potential (homogeneous - inhomogeneous)
    diff_img_v.node_data = inh_idealdata.volt(:,inj_idx)-hom_idealdata.volt(:,inj_idx); 
    
    subplot(ceil(sqrt(n_injections)),ceil(sqrt(n_injections)),inj_idx)
    show_slices(diff_img_v,[inf,inf,slice_lvl]) 
end
sgtitle('Potential distribution varying current electrodes (Differential)')

figure %conductivity reference
show_slices(inh_img_g,[inf,inf,slice_lvl])
sgtitle('Conductivity distribution for fixed cross-section (Inhomogeneous)')

%% PLOTS: Fixed injection, varying z_cross

figure
for slice_lvl = (1/n_plots:1/n_plots:1)*z_height 
    subplot(floor(sqrt(n_plots)),ceil(sqrt(n_plots)),round(n_plots*slice_lvl/z_height))
    show_slices(diff_img_v,[inf,inf,slice_lvl]) 
end
sgtitle('Potential distribution varying Z cross-section (Differential)')

figure %conductivity reference
for slice_lvl = (1/n_plots:1/n_plots:1)*z_height 
    subplot(ceil(sqrt(n_plots)),ceil(sqrt(n_plots)),round(n_plots*slice_lvl/z_height))
    show_slices(inh_img_g,[inf,inf,slice_lvl]) 
end
sgtitle('Conductivity distribution varying Z cross-section (Inhomogeneous)')

%% PLOTS: Fixed injection, rotating xy_cross

figure
for angle = 0:(2*pi)/n_rot:2*pi*(1-1/n_rot)
    %rotating nodes
    rot = [cos(angle) -sin(angle);sin(angle) cos(angle)];
    hom_img_v.fwd_model.nodes(:,[1 2]) = [x_zero y_zero]*transp(rot);
    
    subplot(ceil(sqrt(n_rot)),ceil(sqrt(n_rot)),1 + round(n_rot*angle/(2*pi)))
    show_slices(hom_img_v,[inf,0,inf]) 
end
sgtitle('Potential distribution rotating sample (Homogeneous)')

figure
for angle = 0:(2*pi)/n_rot:2*pi*(1-1/n_rot)
    %rotating nodes
    rot = [cos(angle) -sin(angle);sin(angle) cos(angle)];
    diff_img_v.fwd_model.nodes(:,[1 2]) = [x_zero y_zero]*transp(rot);
    
    subplot(ceil(sqrt(n_rot)),ceil(sqrt(n_rot)),1 + round(n_rot*angle/(2*pi)))
    show_slices(diff_img_v,[inf,0,inf]) 
end
sgtitle('Potential distribution rotating sample (Differential)')

figure %reference
for angle = 0:(2*pi)/n_rot:2*pi*(1-1/n_rot)
    %rotating nodes
    rot = [cos(angle) -sin(angle);sin(angle) cos(angle)];
    inh_img_g.fwd_model.nodes(:,[1 2]) = [x_zero y_zero]*transp(rot);
    
    subplot(ceil(sqrt(n_rot)),ceil(sqrt(n_rot)),1 + round(n_rot*angle/(2*pi)))
    show_slices(inh_img_g,[inf,0,inf]) 
end
sgtitle('Conductivity distribution rotating sample (Inhomogeneous)')

end


