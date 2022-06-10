.include "./lib/libpow.asm"

@ Data Section
.data
.align 4
  two_ldexp: .single 2.0

@ Code Section
.section .text
.arm
.arch armv8-a

ldexp:
  VPUSH.F32 {S2}
  VMOV.F32 S2, S0
  LDR  R0, =two_ldexp
  VLDR S0, [R0]

  PUSH {LR}
  BL   pow
  POP  {LR}

  VMUL.F32 S0, S0, S2
  VPOP.F32 {S2}
  BX   LR
