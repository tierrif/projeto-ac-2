@ Data Section
.data
.align 4
  zero_fabs: .single 0.0

@ Code Section
.section .text
.arm
.arch armv8-a

fabs:
  VPUSH      {S1}
  PUSH       {R0}

  LDR        R0, =zero_fabs
  VLDR       S1, [R0]
  VCMP.F32   S0, S1
  VMRS       APSR_nzcv, FPSCR

  @ Negar os bits do valor binário de S0 de modo a se tornar positivo.
  VNEGLT.F32 S0, S0

  VPOP.F32   {S1}
  POP        {R0}

  BX   LR
