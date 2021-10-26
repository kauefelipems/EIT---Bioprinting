function fmdl_inv = phantom_FEM_inv(n_elec)
%% Phantom FEM generation for inverse problem(based on Wu et al., 2020)
%Mesh Settings
ele_mesh_inv = 50e-3;
mesh_inv = 200e-3;

%Electrodes
elec_rad = 0.48e-3;
gnd_rad = 0.2e-3;
offset = elec_rad;

%Well Shape
diam = 15e-3;
height = 7e-3;

%Defining homogeneous shape using NetGen primitives
shape_hom = [strcat('solid cyl = cylinder (0,0,0; 0,0,1; ', num2str(diam/2), '); \n'), ...
             'solid bottom= plane(0,0,0;0,0,-1);\n' ...
             strcat('solid top= plane(0,0,', num2str(height), ';0,0, 1);\n') ...
             strcat('solid mainobj= top and bottom and cyl -maxh=', num2str(mesh_inv), ';\n')];    
 
%Electrode position (bottom around the well and center gnd)
th = linspace(0,2*pi,n_elec+1)'; th(end) = [];
cs = (diam/2-elec_rad-offset)*[cos(th), sin(th)];
elec_pos = [cs , zeros(n_elec,1), zeros(n_elec,1),  zeros(n_elec,1), -ones(n_elec,1); %working electrodes
            0, 0, 0, 0, 0, -1]; %gnd electrode
        
%Electrode shape (circular)        
elec_shape=[elec_rad*ones(n_elec,1), 0*ones(n_elec,1), ele_mesh_inv*ones(n_elec,1); %working electrodes
             gnd_rad, 0, ele_mesh_inv]; %gnd electrode
         
%Surface with electrodes            
elec_obj = 'bottom';

%Generating FEM model using NetGen
fmdl_inv = ng_mk_gen_models(shape_hom, elec_pos, elec_shape, elec_obj);

%Defining center electrode as ground and removing it 
%from electrode array (to not be counted during stimulation)
fmdl_inv.gnd_node = fmdl_inv.electrode(17).nodes;
fmdl_inv.electrode = fmdl_inv.electrode(1:end-1); 

end