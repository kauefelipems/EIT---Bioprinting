%% Setting file path folders

mydir = '/home/kauefelipems/EIT---Bioprinting/data';

netlist_path = [mydir '/samples'];
testbench_path = [mydir '/stimulus'];
pspice_output_path = [mydir '/pspice'];
firmware_interface_path = [mydir '/UTOM_FILES'];

mkdir(netlist_path);
mkdir(testbench_path);
mkdir(pspice_output_path);
mkdir(firmware_interface_path);