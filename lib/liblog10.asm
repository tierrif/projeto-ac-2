.include "./lib/libln.asm"

@ Data Section
.data
.align 4
  ten_log10: .single 10.0

@ Code Section
.section .text
.arm
.arch armv8-a

log10:
  @ log10(x) = ln(x)/ln(10)
  PUSH {LR}
  BL   ln
  POP  {LR}
  VMOV.F32 S1, S0

  LDR  R0, =ten_log10
  VLDR S0, [R0]
  PUSH {LR}
  BL   ln
  POP  {LR}
  VDIV.F32 S0, S1, S0
  BX   LR
