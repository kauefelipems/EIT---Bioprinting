%% Simulate loaded phantom data

% store the internal node potentials during the foward problem solution
hom_img.fwd_solve.get_all_meas = 1;
inh_img.fwd_solve.get_all_meas = 1;

% solve ideal data set
hom_idealdata=fwd_solve(hom_img);
inh_idealdata=fwd_solve(inh_img); %ideal data from the foward solver

% plot electrode measurement differences
figure
plot(real(inh_idealdata.meas) - real(hom_idealdata.meas))
title('Real measurement difference')
figure
plot(imag(inh_idealdata.meas) - imag(hom_idealdata.meas))
title('Imaginary measurement difference')

%% Simulate differential foward potentials

[hom_img_v, diff_img_v] = potential_imgs(hom_img, inh_img, hom_idealdata, inh_idealdata, 7e-3);
hom_sens = sensitivity_imgs(hom_img, 7e-3);