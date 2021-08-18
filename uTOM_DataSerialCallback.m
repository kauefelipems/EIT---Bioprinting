%% Serial Read Callback
function uTOM_DataSerialCallback(src,~)
    global serial_data;
    global ready_flag;
    global count;

    raw_data = char(num2cell(readline(src))); %array of chars

    serial_data(count) = uint8(reshape(raw_data, 1, [])); %array of uint8 numbers
    
    ready_flag = 1;
end