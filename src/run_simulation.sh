#!/bin/bash

rm -f simulation.out simulation.vcd

iverilog -o simulation.out \
  *.v

if [ $? -ne 0 ]; then
  echo "Error en la compilación."
  exit 1
fi

vvp simulation.out

if [ ! -f simulation.vcd ]; then
  echo "La simulación no generó un archivo VCD. Revisa el testbench."
  exit 1
fi

gtkwave simulation.vcd &