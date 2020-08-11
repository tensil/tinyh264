
# NOTE: make sure that em++ is in the path, usually with `source <OPTSDK>/emsdk_env.sh`
CC = emcc
CXX = em++
EXE = obj/TinyH264.js
SOURCES = $(wildcard native/*.c)
OBJDIR = obj
OBJS = $(addprefix $(OBJDIR)/, $(addsuffix .o, $(basename $(notdir $(SOURCES)))))
UNAME_S := $(shell uname -s)

all: executable
debug: executable

##---------------------------------------------------------------------
## OPTSCRIPTEN OPTIONS
##---------------------------------------------------------------------

# OPTS += -std=c++17


all: OPTS += -O3
all: OPTS += -flto
# all: LDFLAGS += --llvm-lto 3 
all: OPTS += --llvm-opts "['-tti', '-domtree', '-tti', '-domtree', '-deadargelim', '-domtree', '-instcombine', '-domtree', '-jump-threading', '-domtree', '-instcombine', '-reassociate', '-domtree', '-loops', '-loop-rotate', '-licm', '-domtree', '-instcombine', '-loops', '-loop-idiom', '-loop-unroll', '-memdep', '-memdep', '-memcpyopt', '-domtree', '-demanded-bits', '-instcombine', '-jump-threading', '-domtree', '-memdep', '-loops', '-licm', '-adce', '-domtree', '-instcombine', '-elim-avail-extern', '-float2int', '-domtree', '-loops', '-loop-rotate', '-demanded-bits', '-instcombine', '-domtree', '-instcombine', '-loops', '-loop-unroll', '-instcombine', '-licm', '-strip-dead-prototypes', '-domtree']"
all: OPTS += -s USE_CLOSURE_COMPILER=1 
all: OPTS += -s AGGRESSIVE_VARIABLE_ELIMINATION=1

debug: OPTS += -g4
debug: OPTS += -D_ERROR_PRINT
# debug: OPTS += -s DEMANGLE_SUPPORT=1
# debug: OPTS += -s EXCEPTION_DEBUG=1
# all: OPTS += -s ASSERTIONS=1
# debug: OPTS += -s ASSERTIONS=2
# all: OPTS += -s DISABLE_EXCEPTION_CATCHING=1
# debug: OPTS += -s DISABLE_EXCEPTION_CATCHING=2

OPTS += -s WASM=1
OPTS += -s MODULARIZE=1
# OPTS += -s 'EXPORT_NAME="TinyH264"'
OPTS += --memory-init-file 0 
OPTS += -s ALLOW_MEMORY_GROWTH=1

OPTS += -s ENVIRONMENT='worker'  
# OPTS += --proxy-to-worker  

OPTS += -s INVOKE_RUN=0 
OPTS += -s DOUBLE_MODE=0
OPTS += -s NO_EXIT_RUNTIME=1
OPTS += -s NO_FILESYSTEM=1 

OPTS += -s EXPORTED_FUNCTIONS=["_malloc","_free","_h264bsdAlloc","_h264bsdFree","_h264bsdInit","_h264bsdDecode","_h264bsdShutdown"]
OPTS += -s EXTRA_EXPORTED_RUNTIME_METHODS=[getValue]

##---------------------------------------------------------------------
## FINAL BUILD FLAGS
##---------------------------------------------------------------------

CPPFLAGS += -Wall -Wformat -Os
CPPFLAGS += $(OPTS)
LIBS += $(OPTS)

##---------------------------------------------------------------------
## BUILD RULES
##---------------------------------------------------------------------

obj/%.o:native/%.c
	$(CC) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<

executable: $(EXE)
	@echo Build complete for $(EXE)

$(EXE): $(OBJS)
	$(CC) -o $@ $^ $(LIBS) $(LDFLAGS)

clean:
	rm -f $(EXE) $(OBJS) build/*

## NOTE: remove key events so that JS can handles keyboard input
##       https://github.com/tensil/lightdesk/issues/175
##       if emscripten changes this line, obviously the sed will not work any more
# copy:
# 	rsync -avr --exclude="*.html" build/tide.* ../../web/public/js/
# 	sed "s/if (dynCall_iiii(callbackfunc, eventTypeId, keyEventData, userData)) e\.preventDefault();/\/\/ if (dynCall_iiii(callbackfunc, eventTypeId, keyEventData, userData)) e.preventDefault();/g" build/tide.js > ../../web/public/js/tide.js