%% Phantom configuration
close all

%Electrode Settings
elec_rad = 0.48e-3;
n_elec = 1;
offset = elec_rad;

%Well Settings
diam = 15e-3;
height = 7e-3;
mesh = 3e-3;
mesh_ele = 0.1e-3;

%Sample Settings
spher_rad = diam/20;
spher_x = 0;
spher_y = 3e-3;
spher_z = spher_rad;

%Conductivities
spheroid_cond = 0.8; 
media_cond = 1;

shape_hom = [strcat('solid cyl = cylinder (0,0,0; 0,0,1; ', num2str(diam/2), '); \n'), ...
             'solid bottom= plane(0,0,0;0,0,-1);\n' ...
             strcat('solid top= plane(0,0,', num2str(height), ';0,0, 1);\n') ...
             strcat('solid mainobj= top and bottom and cyl -maxh=', num2str(mesh), ';\n')];

shape_inh = [strcat('solid cyl = cylinder (0,0,0; 0,0,1; ', num2str(diam/2), '); \n'), ...
             'solid bottom= plane(0,0,0;0,0,-1) ;\n' ...
             strcat('solid top= plane(0,0,', num2str(height), ';0,0, 1) ;\n') ...
             strcat('solid spheroid= sphere(',num2str(spher_x),',',num2str(spher_y),',',num2str(spher_z),';',...
                    num2str(spher_rad),'); tlo spheroid -maxh= 1e-3;\n') ...
             strcat('solid mainobj= top and bottom and cyl and not spheroid -maxh=', num2str(mesh), ';\n')];         
         
 th = linspace(0,2*pi,n_elec+1)'; th(end) = [];
 cs = (diam/2-elec_rad-offset)*[cos(th), sin(th)];
 elec_pos = [cs , th*0, th*0,  th*0, - ones(n_elec,1)];
          
 elec_shape=[elec_rad, 0, mesh_ele];
 elec_obj = 'bottom';
 
 fmdl = ng_mk_gen_models(shape_hom, elec_pos, elec_shape, elec_obj);
 fmdl2 = ng_mk_gen_models(shape_inh, elec_pos, elec_shape, elec_obj);
 
 show_fem(fmdl);
 figure
 show_fem(fmdl2);
