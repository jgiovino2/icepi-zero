#!/bin/bash
# Complete independent source compilation chain
iverilog -g2012 -s tb_top -o tb.vvp tb_top.sv top.sv fastdec_32.sv fastdec.sv

if [ $? -ne 0 ]; then
  echo "Hardware or Testbench compilation failed!"
  exit 1
fi

# Execute the simulation matrix
vvp -g tb.vvp

# Launch your GTKWave analyzer
if command -v gtkwave >/dev/null 2>&1; then
  gtkwave tb.vcd &
else
  echo "gtkwave not found; view tb.vcd with your custom viewer"
fi
