#!/bin/bash

# Eliminar archivos anteriores de simulación
rm -f simulation.out simulation.vcd

# Compilar los archivos Verilog
iverilog -o simulation.out \
  top.v \
  testbench2.v \
  arm.v \
  controller.v \
  datapath.v \
  decode.v \
  condlogic.v \
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
  flopen_de.v \
  flopen_em.v \
  flopen_mw.v \
  flopencont_de.v \
  flopencont_em.v \
  flopencont_mw.v \
  hazard.v \
  cond_unit.v \
  flopenrc.v \
  floprc.v

# Verificar si la compilación fue exitosa
if [ $? -ne 0 ]; then
  echo "Error en la compilación."
  exit 1
fi

# Ejecutar la simulación
vvp simulation.out

# Verificar si el archivo VCD se generó
if [ ! -f simulation.vcd ]; then
  echo "La simulación no generó un archivo VCD. Revisa el testbench."
  exit 1
fi

# Abrir el archivo VCD en GTKWave
gtkwave simulation.vcd &