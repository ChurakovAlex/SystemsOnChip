-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Wed Mar 20 17:28:12 2024
-- Host        : DESKTOP-LUOGMV1 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/SoC/activecore/designs/rtl/sigma/syn/syn_6stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_stub.vhdl
-- Design      : sys_clk
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-3
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sys_clk is
  Port ( 
    clk_out1 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end sys_clk;

architecture stub of sys_clk is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out1,reset,locked,clk_in1";
begin
end;
