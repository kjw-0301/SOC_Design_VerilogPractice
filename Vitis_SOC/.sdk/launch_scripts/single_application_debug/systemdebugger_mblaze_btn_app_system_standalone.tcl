connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Basys3 210183BB7F95A" && level==0} -index 0
fpga -file C:/Users/minkyu/Documents/GitHub/SOC_Design_VerilogPractice/Vitis_SOC/Mblaze_btn_app/_ide/bitstream/micro_blaze_button_wrapper.bit
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow C:/Users/minkyu/Documents/GitHub/SOC_Design_VerilogPractice/Vitis_SOC/Mblaze_btn_app/Debug/Mblaze_btn_app.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
