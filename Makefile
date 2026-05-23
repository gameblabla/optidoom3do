NAME       = optidoom
ISONAME    = iso/$(NAME).iso
FILESYSTEM = takeme
LAUNCHME   = $(FILESYSTEM)/LaunchMe
STACKSIZE  = 10000

DEVKIT_DEFAULT := $(abspath ../3do-devkit)

ifeq ($(origin TDO_DEVKIT_PATH),undefined)
  ifneq ($(wildcard .devkit-path),)
    TDO_DEVKIT_PATH := $(shell cat .devkit-path)
  else
    TDO_DEVKIT_PATH := $(DEVKIT_DEFAULT)
  endif
endif

ifeq ($(OS),Windows_NT)
  ifeq ($(origin MSYSTEM),undefined)
    IS_POSIX_SHELL := 0
  else
    IS_POSIX_SHELL := 1
  endif
else
  IS_POSIX_SHELL := 1
endif

ifeq ($(IS_POSIX_SHELL),1)
  ifeq ($(OS),Windows_NT)
    PATH := $(TDO_DEVKIT_PATH)/bin/compiler/win:$(TDO_DEVKIT_PATH)/bin/tools/win:$(TDO_DEVKIT_PATH)/bin/buildtools/win:$(PATH)
  else
    PATH := $(TDO_DEVKIT_PATH)/bin/compiler/linux:$(TDO_DEVKIT_PATH)/bin/tools/linux:$(TDO_DEVKIT_PATH)/bin/buildtools/linux:$(PATH)
  endif
else
  PATH := $(TDO_DEVKIT_PATH)\bin\compiler\win;$(TDO_DEVKIT_PATH)\bin\tools\win;$(TDO_DEVKIT_PATH)\bin\buildtools\win;$(PATH)
endif

.DEFAULT_GOAL := all

BUILD_DIR    = build
OBJ_DIR      = $(BUILD_DIR)/obj
LIB_BUILD    = $(BUILD_DIR)/lib
CASE_INCLUDE = $(BUILD_DIR)/include
ASSET_SOURCE = ISOdecompile/CDextra

INCPATH  = $(TDO_DEVKIT_PATH)/include
LIBPATH  = $(TDO_DEVKIT_PATH)/lib
STARTUP  = $(LIBPATH)/3do/cstartup.o

INCFLAGS = -I$(CASE_INCLUDE) -Isource -Ilib/burger -Ilib/string -Ilib/intmath -Ilib/mvelib \
           -I$(INCPATH)/3do -I$(INCPATH)/community -I$(INCPATH)/ttl

ifeq ($(DEBUG),1)
OPT      = -O0
DEFFLAGS = -DDEBUG=1
else
OPT      = -O2 -Otime
DEFFLAGS = -DNDEBUG=1 -DDEBUG=0
endif

CFLAGS  = $(OPT) -bigend -za1 -zi4 -fa -fpu none -arch 3 -apcs "3/32/fp/swst/wide/softfp"
ASFLAGS = -bigend -fpu none -arch 3 -apcs "3/32/fp/swst"
LDFLAGS = -match 0x1 -nodebug -noscanlib -nozeropad -verbose -remove -aif -reloc -dupok -ro-base 0 -sym $(BUILD_DIR)/$(NAME).sym

SDK_LIBS = \
	$(LIBPATH)/3do/3dlib.lib \
	$(LIBPATH)/3do/audio.lib \
	$(LIBPATH)/3do/clib.lib \
	$(LIBPATH)/3do/codec.lib \
	$(LIBPATH)/3do/compression.lib \
	$(LIBPATH)/3do/cpluslib.lib \
	$(LIBPATH)/3do/DataAcq.lib \
	$(LIBPATH)/3do/DataAcqShuttle.lib \
	$(LIBPATH)/3do/DS.lib \
	$(LIBPATH)/3do/DSShuttle.lib \
	$(LIBPATH)/3do/exampleslib.lib \
	$(LIBPATH)/3do/filesystem.lib \
	$(LIBPATH)/3do/graphics.lib \
	$(LIBPATH)/3do/input.lib \
	$(LIBPATH)/3do/international.lib \
	$(LIBPATH)/3do/intmath.lib \
	$(LIBPATH)/3do/lib3do.lib \
	$(LIBPATH)/3do/music.lib \
	$(LIBPATH)/3do/mvelib.lib \
	$(LIBPATH)/3do/operamath.lib \
	$(LIBPATH)/3do/pgl.lib \
	$(LIBPATH)/3do/string.lib \
	$(LIBPATH)/3do/Subscriber.lib \
	$(LIBPATH)/3do/swi.lib \
	$(LIBPATH)/community/cpplib.lib \
	$(LIBPATH)/community/example_folio.lib \
	$(LIBPATH)/community/svc_funcs.lib \
	$(LIBPATH)/community/svc_mem.lib \
	$(LIBPATH)/3do/armlib.32b

LOCAL_LIBS = \
	$(LIB_BUILD)/burger/burger.lib \
	$(LIB_BUILD)/string/string.lib \
	$(LIB_BUILD)/intmath/intmath.lib \
	$(LIB_BUILD)/mvelib/mvelib.lib

LIBS = $(LOCAL_LIBS) $(SDK_LIBS)

SOURCE_SRCS_C = $(wildcard source/*.c)
SOURCE_SRCS_S = $(wildcard source/*.s)
SOURCE_OBJS   = $(SOURCE_SRCS_S:source/%.s=$(OBJ_DIR)/source/%.s.o) \
                $(SOURCE_SRCS_C:source/%.c=$(OBJ_DIR)/source/%.c.o)

BURGER_SRCS_C = $(filter-out lib/burger/test.c,$(wildcard lib/burger/*.c))
BURGER_SRCS_S = $(wildcard lib/burger/*.s)
BURGER_OBJS   = $(BURGER_SRCS_S:lib/burger/%.s=$(OBJ_DIR)/lib/burger/%.s.o) \
                $(BURGER_SRCS_C:lib/burger/%.c=$(OBJ_DIR)/lib/burger/%.c.o)

STRING_SRCS_S = $(wildcard lib/string/*.s)
STRING_OBJS   = $(STRING_SRCS_S:lib/string/%.s=$(OBJ_DIR)/lib/string/%.s.o)

INTMATH_SRCS_C = $(wildcard lib/intmath/*.c)
INTMATH_SRCS_S = $(filter-out lib/intmath/im_div.s,$(wildcard lib/intmath/*.s))
INTMATH_OBJS   = $(INTMATH_SRCS_S:lib/intmath/%.s=$(OBJ_DIR)/lib/intmath/%.s.o) \
                 $(INTMATH_SRCS_C:lib/intmath/%.c=$(OBJ_DIR)/lib/intmath/%.c.o)

MVELIB_SRCS_C = $(wildcard lib/mvelib/*.c)
MVELIB_SRCS_S = lib/mvelib/nfadvance.s
MVELIB_OBJS   = $(MVELIB_SRCS_S:lib/mvelib/%.s=$(OBJ_DIR)/lib/mvelib/%.s.o) \
                $(MVELIB_SRCS_C:lib/mvelib/%.c=$(OBJ_DIR)/lib/mvelib/%.c.o)

INCLUDE_ALIASES = \
	BlockFile.h Burger.h BURGER.h Doom.h DoomRez.h Event.h Filefunctions.h FileFunctions.h \
	FileStreamFunctions.h Graphics.h Init3do.h IntMath.h Portfolio.h SoundFile.h Sounds.h \
	States.h Stdio.h String.h Task.h TimerUtils.h

all: $(LAUNCHME) modbin iso encrypt-iso

$(CASE_INCLUDE)/.touched:
	mkdir -p "$(CASE_INCLUDE)"
	for h in source/*.h lib/burger/*.h lib/string/*.h lib/intmath/*.h lib/mvelib/*.h; do \
		[ -f "$$h" ] || continue; \
		ln -sf "$$(cd "$$(dirname "$$h")" && pwd)/$$(basename "$$h")" "$(CASE_INCLUDE)/$$(basename "$$h")"; \
	done
	for alias in $(INCLUDE_ALIASES); do \
		lower=$$(printf '%s\n' "$$alias" | tr 'A-Z' 'a-z'); \
		for dir in source lib/burger lib/string lib/intmath lib/mvelib "$(INCPATH)"/3do; do \
			if [ -f "$$dir/$$lower" ]; then \
				ln -sf "$$(cd "$$dir" && pwd)/$$lower" "$(CASE_INCLUDE)/$$alias"; \
				break; \
			fi; \
		done; \
	done
	touch "$@"

$(OBJ_DIR)/source $(OBJ_DIR)/lib/burger $(OBJ_DIR)/lib/string $(OBJ_DIR)/lib/intmath $(OBJ_DIR)/lib/mvelib $(LIB_BUILD)/burger $(LIB_BUILD)/string $(LIB_BUILD)/intmath $(LIB_BUILD)/mvelib $(FILESYSTEM):
	mkdir -p "$@"

$(LAUNCHME): $(FILESYSTEM) $(SOURCE_OBJS) $(LOCAL_LIBS)
	armlink -o "$@" $(LDFLAGS) $(STARTUP) $(LIBS) $(SOURCE_OBJS)

modbin: $(LAUNCHME)
	modbin --name="$(NAME)" --time --stack=$(STACKSIZE) "$(LAUNCHME)" "$(LAUNCHME)"

iso/.touched:
	mkdir -p iso
	touch "$@"

iso: iso/.touched $(LAUNCHME)
	if [ -d "$(ASSET_SOURCE)" ]; then cp -R "$(ASSET_SOURCE)"/. "$(FILESYSTEM)"/; fi
	3doiso -in "$(FILESYSTEM)" -out "$(ISONAME)"

encrypt-iso: $(ISONAME)
	3DOEncrypt genromtags "$(ISONAME)"

$(LIB_BUILD)/burger/burger.lib: $(LIB_BUILD)/burger $(BURGER_OBJS)
	armlib -c "$@" $(BURGER_OBJS)
	armlib -o "$@"

$(LIB_BUILD)/string/string.lib: $(LIB_BUILD)/string $(STRING_OBJS)
	armlib -c "$@" $(STRING_OBJS)
	armlib -o "$@"

$(LIB_BUILD)/intmath/intmath.lib: $(LIB_BUILD)/intmath $(INTMATH_OBJS)
	armlib -c "$@" $(INTMATH_OBJS)
	armlib -o "$@"

$(LIB_BUILD)/mvelib/mvelib.lib: $(LIB_BUILD)/mvelib $(MVELIB_OBJS)
	armlib -c "$@" $(MVELIB_OBJS)
	armlib -o "$@"

$(OBJ_DIR)/source/%.c.o: source/%.c $(CASE_INCLUDE)/.touched | $(OBJ_DIR)/source
	armcc $(INCFLAGS) $(DEFFLAGS) $(CFLAGS) -c "$<" -o "$@"

$(OBJ_DIR)/source/%.s.o: source/%.s $(CASE_INCLUDE)/.touched | $(OBJ_DIR)/source
	armasm $(INCFLAGS) $(ASFLAGS) "$<" -o "$@"

$(OBJ_DIR)/lib/burger/%.c.o: lib/burger/%.c $(CASE_INCLUDE)/.touched | $(OBJ_DIR)/lib/burger
	armcc $(INCFLAGS) $(DEFFLAGS) $(CFLAGS) -c "$<" -o "$@"

$(OBJ_DIR)/lib/burger/%.s.o: lib/burger/%.s $(CASE_INCLUDE)/.touched | $(OBJ_DIR)/lib/burger
	armasm $(INCFLAGS) $(ASFLAGS) "$<" -o "$@"

$(OBJ_DIR)/lib/string/%.s.o: lib/string/%.s $(CASE_INCLUDE)/.touched | $(OBJ_DIR)/lib/string
	armasm $(INCFLAGS) $(ASFLAGS) "$<" -o "$@"

$(OBJ_DIR)/lib/intmath/%.c.o: lib/intmath/%.c $(CASE_INCLUDE)/.touched | $(OBJ_DIR)/lib/intmath
	armcc $(INCFLAGS) $(DEFFLAGS) $(CFLAGS) -c "$<" -o "$@"

$(OBJ_DIR)/lib/intmath/%.s.o: lib/intmath/%.s $(CASE_INCLUDE)/.touched | $(OBJ_DIR)/lib/intmath
	armasm $(INCFLAGS) $(ASFLAGS) "$<" -o "$@"

$(OBJ_DIR)/lib/mvelib/%.c.o: lib/mvelib/%.c $(CASE_INCLUDE)/.touched | $(OBJ_DIR)/lib/mvelib
	armcc $(INCFLAGS) $(DEFFLAGS) $(CFLAGS) -c "$<" -o "$@"

$(OBJ_DIR)/lib/mvelib/%.s.o: lib/mvelib/%.s $(CASE_INCLUDE)/.touched | $(OBJ_DIR)/lib/mvelib
	armasm $(INCFLAGS) $(ASFLAGS) "$<" -o "$@"

clean:
	rm -rf "$(BUILD_DIR)" "iso" "$(FILESYSTEM)/LaunchMe"

distclean: clean
	rm -rf "$(FILESYSTEM)"

run: $(ISONAME)
	run-iso "$(ISONAME)"

.PHONY: all clean distclean modbin encrypt-iso run
