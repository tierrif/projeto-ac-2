.include "./lib/libcoshsinh.asm"

@ Data Section
.data

@ Code Section
.section .text
.arm
.arch armv8-a

tanh:
  VMOV.F32 S2, S0
  PUSH {LR}
  BL   cosh
  POP  {LR}
  VMOV.F32 S1, S0
  VMOV.F32 S0, S2
  PUSH {LR}
  BL   sinh
  POP  {LR}

  VDIV.F32 S0, S0, S1

  BX   LR
