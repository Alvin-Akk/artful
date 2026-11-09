# Directories
MSPGCC_ROOT_DIR    = $(TOOLS_PATH)/msp430-gcc
MSPGCC_BIN_DIR     = $(MSPGCC_ROOT_DIR)/bin
MSPGCC_INCLUDE_DIR = $(MSPGCC_ROOT_DIR)/include
TI_CCS_DIR         = $(TOOLS_PATH)/ccs2041/ccs
DEBUG_BIN_DIR      = $(TI_CCS_DIR)/ccs_base/DebugServer/bin
DEBUG_CONFIG       = msp430g2553.ccxml

BUILD_DIR  = build
OBJ_DIR    = $(BUILD_DIR)/obj
BIN_DIR    = $(BUILD_DIR)/bin

SRC_DIR = src

INCLUDE_DIRS = $(MSPGCC_INCLUDE_DIR) \
               $(SRC_DIR)
LIB_DIRS     = $(MSPGCC_INCLUDE_DIR)

# Toolchain
CC      = $(MSPGCC_BIN_DIR)/msp430-elf-gcc
OBJCOPY = $(MSPGCC_BIN_DIR)/msp430-elf-objcopy
RM       = rm -rf
DSLITE   = $(DEBUG_BIN_DIR)/DSLite.exe
CPPCHECK = cppcheck

# Files
TARGET  = $(BIN_DIR)/sumo

# Paths are relative to SRC_DIR
SOURCES = main.c \
          app/drive.c \
          app/enemy.c \
          drivers/i2c.c \
          drivers/uart.c

OBJECTS = $(patsubst %.c,$(OBJ_DIR)/%.o,$(SOURCES))

# Flags
MCU = msp430g2553

WFLAGS      = -Wall -Wextra -Werror -Wshadow
CFLAGS      = -mmcu=$(MCU) $(WFLAGS) $(addprefix -I,$(INCLUDE_DIRS)) -Og -g
LDFLAGS     = -mmcu=$(MCU) $(addprefix -L,$(LIB_DIRS))

# Build
all: $(TARGET).hex

# Linking
$(TARGET): $(OBJECTS)
	@mkdir -p $(dir $@)
	$(CC) $(LDFLAGS) $^ -o $@

# Convert ELF to Intel HEX
$(TARGET).hex: $(TARGET)
	$(OBJCOPY) -O ihex $< $@

# Compiling
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Phonies
.PHONY: all clean flash cppcheck

clean:
	$(RM) $(BUILD_DIR)

# Static analysis (source paths are relative to SRC_DIR)
cppcheck:
	@$(CPPCHECK) --quiet --enable=all --error-exitcode=1 \
		--inline-suppr \
		$(addprefix -I,$(INCLUDE_DIRS)) \
		$(addprefix $(SRC_DIR)/,$(SOURCES)) \
		-i external/printf

# Flash with TI DSLite (load = program the chip and run it)
flash: $(TARGET).hex
	$(DSLITE) load -c $(DEBUG_CONFIG) $<


