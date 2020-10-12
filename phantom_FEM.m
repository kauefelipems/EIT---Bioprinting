%% Phantom configuration
close all

%Mesh Settings
ele_mesh = .1e-3;
mesh = 1e-3;
spher_mesh = .5e-3;

%Electrodes
n_elec = 16;
elec_rad = 0.48e-3;
gnd_rad = 0.2e-3;
offset = elec_rad;

%Well Shape
diam = 15e-3;
height = 7e-3;

%Sample Shape
spher_rad = diam/20;
spher_x = 0;
spher_y = 3e-3;
spher_z = spher_rad;

%Conductivities
spher_cond = 0.8; 
media_cond = 1;

%Defining homogeneous shape using NetGen primitives
shape_hom = [strcat('solid cyl = cylinder (0,0,0; 0,0,1; ', num2str(diam/2), '); \n'), ...
             'solid bottom= plane(0,0,0;0,0,-1);\n' ...
             strcat('solid top= plane(0,0,', num2str(height), ';0,0, 1);\n') ...
             strcat('solid mainobj= top and bottom and cyl -maxh=', num2str(mesh), ';\n')];

%Defining inhomogeneous shape (with spheroid) using NetGen primitives
shape_inh = [strcat('solid cyl = cylinder (0,0,0; 0,0,1; ', num2str(diam/2), '); \n'), ...
             'solid bottom= plane(0,0,0;0,0,-1) ;\n' ...
             strcat('solid top= plane(0,0,', num2str(height), ';0,0, 1) ;\n') ...
             strcat('solid spheroid= sphere(',num2str(spher_x),',',num2str(spher_y),',',num2str(spher_z),';',...
                    num2str(spher_rad),'); tlo spheroid -maxh=', num2str(spher_mesh), ';\n') ...
             strcat('solid mainobj= top and bottom and cyl and not spheroid -maxh=', num2str(mesh), ';\n')];         
 
%Electrode position (bottom around the well and center gnd)
th = linspace(0,2*pi,n_elec+1)'; th(end) = [];
cs = (diam/2-elec_rad-offset)*[cos(th), sin(th)];
elec_pos = [cs , zeros(n_elec,1), zeros(n_elec,1),  zeros(n_elec,1), -ones(n_elec,1); %working electrodes
            0, 0, 0, 0, 0, -1]; %gnd electrode
        
%Electrode shape (circular)        
elec_shape=[elec_rad*ones(n_elec,1), 0*ones(n_elec,1), ele_mesh*ones(n_elec,1); %working electrodes
             gnd_rad, 0, ele_mesh]; %gnd electrode
         
%Surface with electrodes            
elec_obj = 'bottom';

%Generating FEM models using NetGen
fmdl = ng_mk_gen_models(shape_hom, elec_pos, elec_shape, elec_obj);
fmdl2 = ng_mk_gen_models(shape_inh, elec_pos, elec_shape, elec_obj);

%Defining center electrode as ground
fmdl.gnd_node = fmdl.electrode(17).nodes;
fmdl2.gnd_node = fmdl2.electrode(17).nodes;

%Plotting models
show_fem(fmdl);
figure
show_fem(fmdl2);
