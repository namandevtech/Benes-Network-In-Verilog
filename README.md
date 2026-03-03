Naman Durve 2026

Project Structure: 
rtl/ folder contains all the Verilog codes for modules. 
rtl/tb folder contains the corresponding testbenches for the modules. 
sim/ contains simulation outputs
Makefile
files.f used by Makefile, you add any new .v files here

Building:
I use Icarus to compile and Virtual Verilog Processor to run the simulation. To visualise the signals I use Surfer. And optionally to 
generate the netlist I use Yosys. 

Use 'make help' to see the different make arguments for compiliing, simulation, viewing, etc, etc. 
