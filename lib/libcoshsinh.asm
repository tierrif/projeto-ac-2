.include "./lib/libexp.asm"

@ Data Section
.data
.align 4
  one_cosh: .single 1.0
.align 4
  two_cosh: .single 2.0

@ Code Section
.section .text
.arm
.arch armv8-a

cosh:
  VPUSH.F32 {S1-S5}
  LDR  R0, =one_cosh
  VLDR S2, [R0]         @ S2 = 1 (constant)
  LDR  R0, =two_cosh
  VLDR S5, [R0]         @ S5 = 2 (constant)

  PUSH {LR}
  BL   exp
  POP  {LR}
  VMOV.F32 S1, S0       @ S1 = e^x
  VDIV.F32 S3, S2, S1   @ S3 = e^-x = 1/e^x

  VADD.F32 S4, S1, S3   @ S4 = e^x - e^-x (numerador)
  VDIV.F32 S4, S4, S5   @ S4 /= 2

  VMOV.F32 S0, S4
  VPOP.F32 {S1-S5}
  BX   LR

sinh:
  VPUSH.F32 {S1-S5}
  LDR  R0, =one_cosh
  VLDR S2, [R0]         @ S2 = 1 (constant)
  LDR  R0, =two_cosh
  VLDR S5, [R0]         @ S5 = 2 (constant)

  PUSH {LR}
  BL   exp
  POP  {LR}
  VMOV.F32 S1, S0       @ S1 = e^x
  VDIV.F32 S3, S2, S1   @ S3 = e^-x = 1/e^x

  VSUB.F32 S4, S1, S3   @ S4 = e^x - e^-x (numerador)
  VDIV.F32 S4, S4, S5   @ S4 /= 2

  VMOV.F32 S0, S4
  VPOP.F32 {S1-S5}
  BX   LR
