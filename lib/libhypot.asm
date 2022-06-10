.include "./lib/libsqrt.asm"

@ Data Section
.data

@ Code Section
.section .text
.arm
.arch armv8-a

hypot:
  VMUL.F32 S0, S0
  VMUL.F32 S1, S1
  VADD.F32 S0, S0, S1

  PUSH {LR}
  BL   sqrt
  POP  {LR}
  BX   LR
