%% Serial Read Callback
function uTOM_DataSerialCallback(src,~)
    persistent counter;

    if isempty(counter)
        counter = 0;
    end
    
    counter = counter + 1;
    display(counter)
    read_buffer = readline(src);
    
    char_string = char(read_buffer);
    data = uint16(char_string);
    previous_data = readmatrix('/home/kauefelipems/EIT---Bioprinting/data/UTOM_FILES/UTOM_EIT_Data7.txt');
    writematrix([previous_data, data], '/home/kauefelipems/EIT---Bioprinting/data/UTOM_FILES/UTOM_EIT_Data7.txt')

    if (counter == 8)
        %Read_Data;
        counter = 0;
        toc
    end
end