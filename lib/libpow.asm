.include "./lib/libln.asm"
.include "./lib/libexp.asm"

@ Data Section
.data

@ Code Section
.section .text
.global main
.arm
.arch armv8-a

pow:
  VPUSH.F32 {S2}
  @ S0 - base, S1 - exponent
  @ pow(base, exponent) = exp(exponent * ln(base))
  PUSH {LR}
  BL   ln
  POP  {LR}

  VMUL.F32 S2, S0, S1
  VMOV.F32 S0, S2

  PUSH {LR}
  BL   exp
  POP  {LR}

  VPOP.F32 {S2}
  BX   LR
