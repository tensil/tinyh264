#!/usr/bin/env bash
set -e
# EMSDK_VERSION="tot-upstream"
#EMSDK_VERSION="latest"

# c_files="$(ls ./native/*.c)"
# exported_functions='-s EXPORTED_FUNCTIONS=["_malloc","_free","_h264bsdAlloc","_h264bsdFree","_h264bsdInit","_h264bsdDecode","_h264bsdShutdown"]'
# exported_runtime_methods='-s EXTRA_EXPORTED_RUNTIME_METHODS=[getValue]'
# EXPORT_FLAGS="$exported_runtime_methods $exported_functions"

#######################################
# Ensures a repo is checked out.
# Arguments:
#   url: string
#   name: string
# Returns:
#   None
#######################################
ensure_repo() {
  local url name
  local "${@}"

  git -C ${name} pull || git clone ${url} ${name}
}

ensure_emscripten() {
  ensure_repo url='https://github.com/emscripten-core/emsdk.git' name='emsdk'
  pushd 'emsdk'
  ./emsdk update-tags
  ./emsdk install ${EMSDK_VERSION}
  ./emsdk activate ${EMSDK_VERSION}
  popd
}

source_emscripten() {
  source ~/Documents/emsdk/emsdk_env.sh
}

# OPTS += -std=c++17
# OPTS += -O3 
# OPTS += -D_ERROR_PRINT
# OPTS += --memory-init-file 0 
# OPTS += -s ALLOW_MEMORY_GROWTH=1
# OPTS += -flto 
# # OPTS += --llvm-opts "['-tti', '-domtree', '-tti', '-domtree', '-deadargelim', '-domtree', '-instcombine', '-domtree', '-jump-threading', '-domtree', '-instcombine', '-reassociate', '-domtree', '-loops', '-loop-rotate', '-licm', '-domtree', '-instcombine', '-loops', '-loop-idiom', '-loop-unroll', '-memdep', '-memdep', '-memcpyopt', '-domtree', '-demanded-bits', '-instcombine', '-jump-threading', '-domtree', '-memdep', '-loops', '-licm', '-adce', '-domtree', '-instcombine', '-elim-avail-extern', '-float2int', '-domtree', '-loops', '-loop-rotate', '-demanded-bits', '-instcombine', '-domtree', '-instcombine', '-loops', '-loop-unroll', '-instcombine', '-licm', '-strip-dead-prototypes', '-domtree']"
# OPTS += -s USE_CLOSURE_COMPILER=1 
# OPTS += -s AGGRESSIVE_VARIABLE_ELIMINATION=1
# OPTS += -s ENVIRONMENT='worker'  
# OPTS += -s NO_EXIT_RUNTIME=1 
# OPTS += -s NO_FILESYSTEM=1 
# OPTS += -s INVOKE_RUN=0 
# OPTS += -s DOUBLE_MODE=0
# OPTS += -s MODULARIZE=1
# OPTS += -s WASM=1

build() {
  # echo $OPTS
  # emcc $c_files $OPTS $EXPORT_FLAGS -o ./src/TinyH264.js
  # mv ./src/TinyH264.wasm ./src/TinyH264.wasm.asset

  [ ! -d "obj" ] && mkdir -p "obj" # Now download it

  make clean
  make -j11 VERBOSE=1
  cp ./obj/TinyH264.wasm ./src/TinyH264.wasm.asset
  cp ./obj/TinyH264.js ./src/TinyH264.js
}

main() {
  source_emscripten
  build
}

main
