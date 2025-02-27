//===- test.cpp -------------------------------------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// (c) Copyright 2021 Xilinx Inc.
//
//===----------------------------------------------------------------------===//

#include "test_library.h"
#include <cassert>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <thread>
#include <unistd.h>
#include <xaiengine.h>

#include "aie_inc.cpp"

int main(int argc, char *argv[]) {

  int n = 1;
  u32 pc0_times[n];

  printf("06_Buffer_Store test start.\n");
  printf("Running %d times ...\n", n);

  int errors = 0;
  for (int iters = 0; iters < n; iters++) {

    aie_libxaie_ctx_t *_xaie = mlir_aie_init_libxaie();
    mlir_aie_init_device(_xaie);

    mlir_aie_clear_tile_memory(_xaie, 1, 3);

    mlir_aie_configure_cores(_xaie);
    mlir_aie_configure_switchboxes(_xaie);
    mlir_aie_initialize_locks(_xaie);
    mlir_configure_dmas(_xaie);

    EventMonitor pc0(_xaie, 1, 3, 0, XAIE_EVENT_ACTIVE_CORE,
                 XAIE_EVENT_CORE_DISABLED_CORE, XAIE_EVENT_NONE_CORE,
                 XAOE_CORE_MOD);

    pc0.set();

    // mlir_aie_print_tile_status(_xaie, 1, 3);

    mlir_aie_start_cores(_xaie);
    pc0_times[iters] = pc0.diff();
    printf("result: %u", pc0_times[iters]);

    int errors = 0;

    mlir_aie_check("After memory writes. Check [3]=14", mlir_aie_read_buffer_a(_xaie, 3), 7,
               errors);
    mlir_aie_deinit_libxaie(_xaie);         
  }
  computeStats(pc0_times, n);
}