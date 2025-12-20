xrun -64 \
     -sv \
     -uvm \
     -timescale 1ns/1ps \
     -f compile.f \
     -top bmu_tb_top \
     -access +rwc \
     +incdir+tb/pkg \
     +incdir+tb/interfaces \
     +incdir+rtl \
     -lwdgen \
     -classlinedebug \
     -enable_tpe \
     -ext_src_info \
     -ext_macro_src_info \
     -coverage all \
     -covoverwrite \
     -covworkdir cov_work \
     +UVM_USE_COLOR
     