#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
# 

echo "This script was generated under a different operating system."
echo "Please update the PATH and LD_LIBRARY_PATH variables below, before executing this script"
exit

if [ -z "$PATH" ]; then
  PATH=E:/vivado2014.4/SDK/2014.4/bin;E:/vivado2014.4/Vivado/2014.4/ids_lite/ISE/bin/nt;E:/vivado2014.4/Vivado/2014.4/ids_lite/ISE/lib/nt:E:/vivado2014.4/Vivado/2014.4/bin
else
  PATH=E:/vivado2014.4/SDK/2014.4/bin;E:/vivado2014.4/Vivado/2014.4/ids_lite/ISE/bin/nt;E:/vivado2014.4/Vivado/2014.4/ids_lite/ISE/lib/nt:E:/vivado2014.4/Vivado/2014.4/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD=`dirname "$0"`
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

# pre-commands:
/bin/touch .init_design.begin.rst
EAStep vivado -log my_uart_top.vdi -applog -m32 -messageDb vivado.pb -mode batch -source my_uart_top.tcl -notrace

