//===- plio_shimmux.mlir ---------------------------------------*- MLIR -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// (c) Copyright 2023 Advanced Micro Devices, Inc.
//
//===----------------------------------------------------------------------===//

//
// This tests the lowering from AIE.switchbox ops to configuration register
// writes for LibXAIEV1. This test targets NoC shim tiles that must configure
// stream switches, and for some PLIOs the shimmux, to connect AIE array
// streams to PL.
//

// RUN: aie-translate --aie-generate-xaie %s | FileCheck %s

// CHECK: mlir_aie_configure_switchboxes
// CHECK: x = 2;
// CHECK: y = 0;
// CHECK: XAie_StrmConnCctEnable(&(ctx->DevInst), XAie_TileLoc(x,y), NORTH, 0, SOUTH, 2);
// CHECK: x = 2;
// CHECK: y = 1;
// CHECK: XAie_StrmConnCctEnable(&(ctx->DevInst), XAie_TileLoc(x,y), NORTH, 0, SOUTH, 0);
// CHECK: x = 2;
// CHECK: y = 0;
// CHECK: XAie_EnableAieToShimDmaStrmPort(&(ctx->DevInst), XAie_TileLoc(x,y), 2);

module {
 AIE.device(xcvc1902) {
  %t20 = AIE.tile(2, 0)
  %t21 = AIE.tile(2, 1)
  %4 = AIE.switchbox(%t20)  {
    AIE.connect<North : 0, South : 2>
  }
  %5 = AIE.switchbox(%t21)  {
    AIE.connect<North : 0, South : 0>
  }
  %6 = AIE.shimmux(%t20)  {
    AIE.connect<North : 2, PLIO : 2>
  }
 }
}
