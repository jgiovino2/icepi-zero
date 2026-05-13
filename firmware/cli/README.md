This utility is meant to be a minimal example for  
externally inspecting and setting registers at runtime  
via the USB uart interface.  
  
The user interaction is locked down and the available  
registers are generated at build time.  
  
This overly simplistic interraction minimizes the size  
of the state machine on the FPGA while allowing user  
flexibility in control.  
  
Every user interation consists of 2 key strokes.  
The first keystroke identifies the register.  
The second keystroke identifies the operation.  
  
?? - help  
?* - help for register  
  
register will have predefines values and step  
  
lets say we have a register called decimation (d) then the user interaction will consist of the following:  
  
d? - show register value  
d+ - set register to next precanned value  
d- - set register to prior precanned value  
  
This apprach simplifies the CLI and locks it down in a way to eliminate user misconfiguration  
  
dr - resets to the default  
  
at build time the file register.txt is convered to HDL  
 
