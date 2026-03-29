export DESIGN_NAME = user_project_wrapper
export DESIGN_NICKNAME = user_project_wrapper
export PLATFORM = sky130hd

export VERILOG_FILES = $(sort $(wildcard $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/*.v))
export SDC_FILE = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export PLACE_DENSITY = 0.55
export VERILOG_DEFINES += -DMPRJ_IO_PADS=38
export DIE_AREA = 0 0 2200 2200
export CORE_AREA = 10 10 2190 2190
