% Creates stimulus sequence for the μ-TOM switching system from an
% EIDORS model

function switch_matrix = sw_commands(model)

        n_injections = length(model.stimulation);
        n_voltages = length(model.stimulation(1).meas_pattern(:,1));
        n_meas = n_injections * n_voltages;

        % Initialize output matrix
        switch_matrix = zeros(n_meas, 4);
        
        k = 1;
        %Sweep through injection electrodes sequence
        for i = 1 : n_injections

            %Get current and measurement electrodes for each injection
            inj = model.stimulation(i).stim_pattern;
            meas = model.stimulation(i).meas_pattern;

            %Sweep through measurement electrodes sequence
            for j = 1 : n_voltages

                %Build control voltage and time vectors (each mux control
                %is a bus with ceil(log2(n_elec)) bit signals, for n_elec
                %binary representation)
                switch_matrix(k,1) = find(inj > 0);
                switch_matrix(k,2) = find(inj < 0);
                switch_matrix(k,3) = find(meas(j,:) > 0);
                switch_matrix(k,4) = find(meas(j,:) < 0);
                
                k=k+1;        
            end    
        end