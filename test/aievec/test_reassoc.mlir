// RUN: aie-opt %s -affine-super-vectorize="virtual-vector-size=8" --aie-vectorize="shift=0" -unaligned-loads-check=false -split-input-file | FileCheck %s

//CHECK-LABEL: func.func @conv2d(%arg0: memref<2048x2048xi32>, %arg1: memref<9xi32>, %arg2: memref<2046x2046xi32>) {
func.func @conv2d (%A: memref<2048x2048xi32>, %B: memref<9xi32>, %C: memref<2046x2046xi32>) {
    affine.for %arg3 = 0 to 2046 {
        affine.for %arg4 = 0 to 2046 {
            //Load the output point
            %ci = affine.load %C[%arg3, %arg4] : memref<2046x2046xi32>

            //First row
            //first point 
            %a11 = affine.load %A[%arg3, %arg4+0] : memref<2048x2048xi32>
            %b11 = affine.load %B[0] : memref<9xi32>
            %p11 = arith.muli %b11, %a11 : i32
            %c11 = arith.addi %p11, %ci : i32

            //second point 
            %a12 = affine.load %A[%arg3, %arg4+1] : memref<2048x2048xi32>
            %b12 = affine.load %B[1] : memref<9xi32>
            %p12 = arith.muli %b12, %a12 : i32
            %c12 = arith.addi %p12, %c11 : i32

            //third point 
            %a13 = affine.load %A[%arg3, %arg4+2] : memref<2048x2048xi32>
            %b13 = affine.load %B[2] : memref<9xi32>
            %p13 = arith.muli %b13, %a13 : i32
            %c13 = arith.addi %p13, %c12 : i32

            //Second row
            //first point 
            %a21 = affine.load %A[%arg3+1, %arg4+0] : memref<2048x2048xi32>
            %b21 = affine.load %B[3] : memref<9xi32>
            %p21 = arith.muli %b21, %a21 : i32
            %c21 = arith.addi %p21, %c13 : i32

            //second point 
            %a22 = affine.load %A[%arg3+1, %arg4+1] : memref<2048x2048xi32>
            %b22 = affine.load %B[4] : memref<9xi32>
            %p22 = arith.muli %b22, %a22 : i32
            %c22 = arith.addi %p22, %c21 : i32

            //third point 
            %a23 = affine.load %A[%arg3+1, %arg4+2] : memref<2048x2048xi32>
            %b23 = affine.load %B[5] : memref<9xi32>
            %p23 = arith.muli %b23, %a23 : i32
            %c23 = arith.addi %p23, %c22 : i32

            //Third row
            //first point 
            %a31 = affine.load %A[%arg3+2, %arg4+0] : memref<2048x2048xi32>
            %b31 = affine.load %B[6] : memref<9xi32>
            %p31 = arith.muli %b31, %a31 : i32
            %c31 = arith.addi %p31, %c23 : i32

            //second point 
            %a32 = affine.load %A[%arg3+2, %arg4+1] : memref<2048x2048xi32>
            %b32 = affine.load %B[7] : memref<9xi32>
            %p32 = arith.muli %a32, %b32 : i32
            %c32 = arith.addi %p32, %c31 : i32

            //third point 
            %a33 = affine.load %A[%arg3+2, %arg4+2] : memref<2048x2048xi32>
            %b33 = affine.load %B[8] : memref<9xi32>
            %p33 = arith.muli %a33, %b33 : i32
            %c33 = arith.addi %p33, %c32 : i32

            //Store accumulated sum
            affine.store %c33, %C[%arg3, %arg4] : memref<2046x2046xi32>
        }
    }
    return
}

//CHECK-NEXT: %c8 = arith.constant 8 : index
//CHECK-NEXT: %c0 = arith.constant 0 : index
//CHECK-NEXT: %0 = aievec.upd %arg1[%c0] {index = 0 : i8, offset = 0 : si32} : memref<9xi32>, vector<8xi32>
//CHECK-NEXT: %1 = aievec.upd %arg1[%c8] {index = 0 : i8, offset = 0 : si32} : memref<9xi32>, vector<8xi32>
//CHECK-NEXT: %c0_0 = arith.constant 0 : index
//CHECK-NEXT: %c2046 = arith.constant 2046 : index
//CHECK-NEXT: %c1 = arith.constant 1 : index
//CHECK-NEXT: scf.for %arg3 = %c0_0 to %c2046 step %c1 {
//CHECK-NEXT: %c1_1 = arith.constant 1 : index
//CHECK-NEXT: %2 = arith.addi %arg3, %c1_1 : index
//CHECK-NEXT: %c2 = arith.constant 2 : index
//CHECK-NEXT: %3 = arith.addi %arg3, %c2 : index
//CHECK-NEXT: %c0_2 = arith.constant 0 : index
//CHECK-NEXT: %c2046_3 = arith.constant 2046 : index
//CHECK-NEXT: %c8_4 = arith.constant 8 : index
//CHECK-NEXT: scf.for %arg4 = %c0_2 to %c2046_3 step %c8_4 {
//CHECK-NEXT: %4 = aievec.upd %arg2[%arg3, %arg4] {index = 0 : i8, offset = 0 : si32} : memref<2046x2046xi32>, vector<8xi32>
//CHECK-NEXT: %5 = aievec.upd %arg0[%arg3, %arg4] {index = 0 : i8, offset = 0 : si32} : memref<2048x2048xi32>, vector<16xi32>
//CHECK-NEXT: %6 = aievec.ups %4 {shift = 0 : i8} : vector<8xi32>, vector<8xi80>
//CHECK-NEXT: %7 = aievec.mac %5, %0, %6 {xoffsets = "0x76543210", xstart = "0", zoffsets = "0x00000000", zstart = "0"} : vector<16xi32>, vector<8xi32>, vector<8xi80>
//CHECK-NEXT: %c1_5 = arith.constant 1 : index
//CHECK-NEXT: %8 = arith.addi %arg4, %c1_5 : index
//CHECK-NEXT: %9 = aievec.upd %arg0[%arg3, %8], %5 {index = 1 : i8, offset = 224 : si32} : memref<2048x2048xi32>, vector<16xi32>
//CHECK-NEXT: %10 = aievec.mac %9, %0, %7 {xoffsets = "0x76543210", xstart = "1", zoffsets = "0x00000000", zstart = "1"} : vector<16xi32>, vector<8xi32>, vector<8xi80>
//CHECK-NEXT: %11 = aievec.mac %9, %0, %10 {xoffsets = "0x76543210", xstart = "2", zoffsets = "0x00000000", zstart = "2"} : vector<16xi32>, vector<8xi32>, vector<8xi80>
//CHECK-NEXT: %12 = aievec.upd %arg0[%2, %arg4] {index = 0 : i8, offset = 0 : si32} : memref<2048x2048xi32>, vector<16xi32>
//CHECK-NEXT: %13 = aievec.mac %12, %0, %11 {xoffsets = "0x76543210", xstart = "0", zoffsets = "0x00000000", zstart = "3"} : vector<16xi32>, vector<8xi32>, vector<8xi80>
//CHECK-NEXT: %14 = aievec.upd %arg0[%2, %8], %12 {index = 1 : i8, offset = 224 : si32} : memref<2048x2048xi32>, vector<16xi32>
//CHECK-NEXT: %15 = aievec.mac %14, %0, %13 {xoffsets = "0x76543210", xstart = "1", zoffsets = "0x00000000", zstart = "4"} : vector<16xi32>, vector<8xi32>, vector<8xi80>
//CHECK-NEXT: %16 = aievec.mac %14, %0, %15 {xoffsets = "0x76543210", xstart = "2", zoffsets = "0x00000000", zstart = "5"} : vector<16xi32>, vector<8xi32>, vector<8xi80>
//CHECK-NEXT: %17 = aievec.upd %arg0[%3, %arg4] {index = 0 : i8, offset = 0 : si32} : memref<2048x2048xi32>, vector<16xi32>
//CHECK-NEXT: %18 = aievec.mac %17, %0, %16 {xoffsets = "0x76543210", xstart = "0", zoffsets = "0x00000000", zstart = "6"} : vector<16xi32>, vector<8xi32>, vector<8xi80>
//CHECK-NEXT: %19 = aievec.upd %arg0[%3, %8], %17 {index = 1 : i8, offset = 224 : si32} : memref<2048x2048xi32>, vector<16xi32>
//CHECK-NEXT: %20 = aievec.mac %19, %0, %18 {xoffsets = "0x76543210", xstart = "1", zoffsets = "0x00000000", zstart = "7"} : vector<16xi32>, vector<8xi32>, vector<8xi80>
//CHECK-NEXT: %21 = aievec.mac %19, %1, %20 {xoffsets = "0x76543210", xstart = "2", zoffsets = "0x00000000", zstart = "0"} : vector<16xi32>, vector<8xi32>, vector<8xi80>
//CHECK-NEXT: %22 = aievec.srs %21 {shift = 0 : i8} : vector<8xi80>, vector<8xi32>
//CHECK-NEXT: vector.transfer_write %22, %arg2[%arg3, %arg4] {in_bounds = [true]} : vector<8xi32>, memref<2046x2046xi32>
