# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with he License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

#######################################################################
## Global Environment Variables for local repo  
#######################################################################

export PDK      ?=     sky130A
export PDK_PATH =      $(PDK_ROOT)/$(PDK)
export VIP_PATH =      $(CORE_VERILOG_PATH)/dv/vip
export FIRMWARE_PATH = $(CORE_VERILOG_PATH)/dv/firmware

#######################################################################
## Caravel Verilog for Integration Tests
#######################################################################

export CARAVEL_VERILOG_PATH ?=  $(DESIGNS)/caravel/verilog
export CORE_VERILOG_PATH    ?=  $(DESIGNS)/caravel_mgmt_soc_litex/verilog
export USER_PROJECT_VERILOG ?=  $(DESIGNS)/verilog

export CARAVEL_PATH = $(CARAVEL_VERILOG_PATH)
export VERILOG_PATH = $(CORE_VERILOG_PATH)

#######################################################################
## Compiler Information 
#######################################################################

export GCC_PATH?=      /home/vsduser/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin
export GCC_PREFIX?=    riscv64-unknown-elf






