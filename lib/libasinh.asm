.include "./lib/libsqrt.asm"
.include "./lib/libln.asm"

@ Data Section
.data
.align 4
  one_asinh:  .single 1.0

@ Code Section
.section .text
.arm
.arch armv8-a

asinh:
  LDR  R0, =one_asinh
  VLDR S1, [R0]        @ 1 constant
  VMOV.F32 S3, S0      @ Conservar x em S3.

  VMUL.F32 S0, S3, S3
  VADD.F32 S0, S1
  PUSH {LR}
  BL   sqrt
  POP  {LR}

  VADD.F32 S0, S3
  PUSH {LR}
  BL   ln
  POP  {LR}

  BX   LR
