.include "./lib/libln.asm"

@ Data Section
.data
.align 4
  one_atanh:  .single 1.0
.align 4
  half_atanh: .single 0.5

@ Code Section
.section .text
.arm
.arch armv8-a

atanh:
  LDR  R0, =one_atanh
  VLDR S1, [R0]        @ 1 constant
  VMOV.F32 S2, S0      @ Conservar x em S2.

  VADD.F32 S3, S1, S2
  VSUB.F32 S4, S1, S2
  VDIV.F32 S0, S3, S4

  PUSH {LR}
  BL   ln
  POP  {LR}

  LDR  R0, =half_atanh
  VLDR S1, [R0]        @ 1/2
  VMUL.F32 S0, S1

  BX   LR
