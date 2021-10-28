%close all
%clear all
clc

%% Parameter Preset:
n_elec = 16;
n_rings= 1;
stim_type = '{ad}'; %stimulation type
measure_type = '{ad}'; %measure type   
options = {'no_meas_current','no_rotate_meas'}; %set stimulation

%%  Solving Inverse Problem

%Load Data
% meas_hom = homg_expdata.meas;
% meas_inh = inh_expdata.meas;
meas_hom = data_struct.hom;
meas_inh = data_struct.inh;

%Build Data Structures
hom_data_real.name = 'Real Homogeneous Data';
hom_data_real.type = 'data';
hom_data_real.time = NaN;
hom_data_real.meas = meas_hom;

inh_data_real.name = 'Real Inhomogeneous Data';
inh_data_real.type = 'data';
inh_data_real.time = NaN;
inh_data_real.meas = meas_inh;


% Create different model for reconstruction
%% Model #1: Simple
params= mk_circ_tank(64, [], n_elec ); 

%% Model #2: More Complete Model using ng_mk_cyl_models()

[stim, meas_select] = mk_stim_patterns(n_elec, n_rings, stim_type,measure_type, ...
                            options, 0.5);
params.stimulation = stim;

%Select FWD Solver to Continue                       
reply = num2str(input('\n Select FWD Solver:\n(1)1st Order \n(2)1st Order 2p5d best w/ Inverse Solver 1 \n'));
 
   switch lower(reply)
       case '1'
          disp('FWD Solver 1st Order')
            params.solve=      'fwd_solve_1st_order';
            params.system_mat= 'system_mat_1st_order';
            params.jacobian=   'jacobian_adjoint';  
          
       case '2'
           disp('FWD Solver 1st Order')          
            params.solve=      'fwd_solve_2p5d_1st_order';
            params.system_mat= 'system_mat_2p5d_1st_order';
            params.jacobian=   'jacobian_adjoint_2p5d_1st_order';      
   end

model_2 = eidors_obj('fwd_model', params);

%figure
% show_fem( model_2 );


%% Create inverse model (NOSER)

%Solver Select
reply = num2str(input('\n(1)NP-Inv w/ Prior TV \n(2) GN-1Step \n(3)TV_pdipm,\n(4)TV_IRLS \n(5)GN-1Step with Prior HPF \n(6)Iterative TV \n(7)GREIT \n(8)Absolute Solver \n(9)BackProjection \n'));
 
   switch lower(reply)
          case {'linear','1'}
          disp('np_Inv_Solve')
    
            clear inv2d;
            inv2d.name= 'EIT inverse';
            inv2d.solve= 'np_inv_solve';
            inv2d.hyperparameter.value = 3e-3; % 3e-3
            inv2d.R_prior= 'prior_TV';
            inv2d.fwd_model.misc.perm_sym= '{y}';
            inv2d.reconst_type= 'difference';
            inv2d.jacobian_bkgnd.value= 1;
            inv2d.fwd_model= model_2;
            inv2d= eidors_obj('inv_model', inv2d);

            % Reconstruct and show experimental image
            img= inv_solve( inv2d, hom_data_real, inh_data_real);
            figure; show_slices(img);
            
          case '2'
            disp('inv_solve_diff_GN_one_step')
         
            clear inv2d;
            inv2d.name= 'EIT inverse NOSER';
            inv2d.solve= @inv_solve_diff_GN_one_step; %NOSER reconstruction
            inv2d.hyperparameter.value = 0.3e-6;
            inv2d.RtR_prior= @prior_noser;
            inv2d.inv_solve_diff_GN_one_step.calc_step_size = 1; %calculate the correct scaling, specify
            inv2d.reconst_type= 'difference';
            inv2d.jacobian_bkgnd.value= 1;
            inv2d.fwd_model= model_2;
            inv2d= eidors_obj('inv_model', inv2d);
           
        % Reconstruct and show experimental image
        img= inv_solve( inv2d, hom_data_real, inh_data_real);
        figure; show_slices(img);
        
          case '3'
            disp('Inv_solve_TV_pdipm')
            
            clear inv2d;
            inv2d.name= 'EIT inverse TV_pdipm';
            inv2d.solve= @inv_solve_TV_pdipm; %TV_pdipm reconstruction
            inv2d.hyperparameter.value = 0.3e-6; %0.3e-6
            inv2d.R_prior= @prior_TV;

            inv2d.reconst_type= 'difference';
            inv2d.jacobian_bkgnd.value= 1;
            inv2d.fwd_model= model_2;
            inv2d= eidors_obj('inv_model', inv2d);

            % Reconstruct and show image
            img= inv_solve(inv2d, hom_data_real, inh_data_real);
            img2= inv_solve(inv2d, hom_data_real, inh_data_real);
            figure; show_slices(img);    
                
         case '4'
            disp('Inv_solve_TV_IRLS')
            
            clear inv2d;
            inv2d.name= 'inv_solve_TV_irls';
            inv2d.solve= @inv_solve_TV_irls; %TV_pdipm reconstruction
            inv2d.hyperparameter.value = 1e-5; %original 1e-5
            inv2d.R_prior= @prior_TV;
            inv2d.parameters.max_iterations= 20;
            inv2d.parameters.keep_iterations=1;
            inv2d.reconst_type= 'difference';
            inv2d.jacobian_bkgnd.value= 1;
            inv2d.fwd_model= model_2;
            inv2d= eidors_obj('inv_model', inv2d);

            % Reconstruct and show image
            img= inv_solve(inv2d, hom_data_real, inh_data_real);
            figure; show_slices(img);
            
         case '5'
            disp('Inv_solve_diff_GN_one_step with HPF Prior')     
            
            clear inv2d;
            inv2d.name= 'inv_solve_diff_GN_one_step';
            inv2d.solve= @inv_solve_diff_GN_one_step; %TV_pdipm reconstruction
            inv2d.hyperparameter.func = @choose_noise_figure;
            inv2d.hyperparameter.noise_figure= 2;
            inv2d.hyperparameter.tgt_elems= 1:4;
            inv2d.RtR_prior=   'prior_gaussian_HPF';
            inv2d.reconst_type= 'difference';
            inv2d.jacobian_bkgnd.value= 1;
            inv2d.fwd_model= model_2;
            inv2d= eidors_obj('inv_model', inv2d);

            % Reconstruct and show image
            img= inv_solve(inv2d, hom_data_real, inh_data_real);
            figure; show_slices(img);            

         case '6'
            disp('Interactive TV Solver')   

            clear invTV;
            invTV.name= 'EIT inverse TV';
            invTV.solve= @inv_solve_TV_pdipm; %TV reconstruction
            invTV.hyperparameter.value = 10^-(3.5);
            invTV.inv_solve_TV_pdipm.alpha1 = 10^-(2);
            invTV.parameters.term_tolerance=  1e-6;
            invTV.R_prior= @prior_TV;
            invTV.parameters.keep_iterations= 1;
            invTV.fwd_model = model_2;
            invTV.parameters.max_iterations = 15;

            invTV.reconst_type= 'difference';
            invTV.jacobian_bkgnd.value= 1;
            invTV= eidors_obj('inv_model', invTV);

            % Reconstruct and show image
            figure
            img = inv_solve(invTV, hom_data_real, inh_data_real)
            show_slices(img);           
            
         case '7'  
            disp('GREIT Solver') 
            
            clear i_grc;
            cyl_shape = [2,1,0.1]; %height, radius, mesh refinement
            elec_pos = [n_elec,1]; %8 electrodes at z = 2
            elec_shape = [0.05]; %circular electrodes (radius, 0, mesh refinement)

            [fmdl,mat_idx] = ng_mk_cyl_models(cyl_shape, elec_pos, ...
                              elec_shape);
            fmdl.stimulation= mk_stim_patterns(n_elec, n_rings, stim_type,measure_type, ...
                                        options, 0.5);
            fmdl = mdl_normalize(fmdl, 0);                       
            fmdl.normalize_measurements = 1;
            opt.noise_figure = 0.4;
            opt.distr = 2; 
            opt.imgsz = [64 64];
            i_grc = mk_GREIT_model(fmdl,.4,[],opt);
            i_grc.RtR_prior = @prior_noser;
            figure
            solution = inv_solve( i_grc, hom_data_real, inh_data_real);
            show_fem(solution); axis equal;
            
        case '8'
            clear invGN;
            invGN.name= 'EIT inverse GN';
            invGN.solve= @inv_solve_gn; %Absolute reconstruction
            invGN.hyperparameter.value = 1.15e-4;
            invGN.parameters.term_tolerance= 1.1e-5;
            invGN.RtR_prior= @prior_laplace;
            invGN.fwd_model = model_2;
            invGN.inv_solve_gn.max_iterations = 10;

            invGN.inv_solve.calc_solution_error = 0;
            invGN.reconst_type= 'static';
            invGN.parameters.min_s = 0.;
            invGN.parameters.max_s = 1.6/4; 

            invGN.reconst_type= 'difference';
            invGN.jacobian_bkgnd.value= 0.1;
            invGN= eidors_obj('inv_model', invGN);

            % Reconstruct and show image
            figure
            img = inv_solve(invGN, hom_data_real, inh_data_real);
            show_slices(img,[inf,inf,1]);

        case '9'
            disp('BackProjection')   
            inv_BP.reconst_type= 'difference';
            inv_BP.solve= @inv_solve_backproj;
            inv_BP.inv_solve_backproj.type= 'naive';
            inv_BP.fwd_model = model_2;
            inv_BP.inv_solve_backproj.type= 'simple_filter';
            % Reconstruct and show image
            figure
            imgr= inv_solve(inv_BP, hom_data_real,inh_data_real);
            show_slices(imgr);   

          otherwise
            disp('Unknown method.')
        end

