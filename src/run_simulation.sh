#!/bin/bash

rm -f simulation.out simulation.vcd

iverilog -o simulation.out \
  top.v \
  testbench.v \
  arm.v \
  controller.v \
  datapath.v \
  decode.v \
  condcheck.v \
  control_unit.v \
  extend.v \
  imem.v \
  dmem.v \
  adder.v \
  alu.v \
  regfile.v \
  mux2.v \
  mux3.v \
  flopenr.v \
  flopr.v \
  hazard.v \
  cond_unit.v \
  flopenrc.v \
  floprc.v \
  shift.v

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