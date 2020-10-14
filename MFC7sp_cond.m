%% MCF-7 Spheroid Cell Model conductivity (based on Wu et al., 2020)
function [spher_cond, media_cond] = MFC7sp_cond(freq)

freq = 10e3;
eps_vac = 8.854e-12; % F/m
w = 2*pi*freq;

%size parameters
rad_cell = 10e-6;
d_m = 5e-9;
%P = n_spher*(rad_cell/rad_spher)^3;
P = 0.46; %volume fraction

%culture medium
sigma_cm_r = 1.5; % S/m
eps_cm_r = 80;
eps_cm = (sigma_cm_r + 1j*w*eps_vac*eps_cm_r)/(1j*w*eps_vac);

%cytoplasm
sigma_c_r = 1.5; % S/m
eps_c_r = 80;
eps_c = (sigma_c_r + 1j*w*eps_vac*eps_c_r)/(1j*w*eps_vac);

%membrane
sigma_mp_r = 0; % S/m
eps_mp_r = 5;
eps_m = (sigma_mp_r + 1j*w*eps_vac*eps_mp_r)/(1j*w*eps_vac);

%Maxwell Garnett equation (effective permittivity)
v = (1-d_m/rad_cell)^3;
eps_cell = eps_m*(2*(1-v)*eps_m + (1+2*v)*eps_c)/((2+v)*eps_c + (1-v)*eps_m);

%Hanai equation (effective permittivity)
n = 1/3;
p = [-(eps_cm^n)/(eps_cm - eps_cell) 0 (1-P) (eps_cell*eps_cm^n)/(eps_cm - eps_cell)];
hanai = roots(p);
spher_perm = hanai.^3;

media_cond = sigma_cm_r + 1j*w*eps_vac*eps_cm_r;
spher_cond = 1j*w*eps_vac*spher_perm(1);
end
