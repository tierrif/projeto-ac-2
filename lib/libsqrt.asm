@ Data Section
.data
.align 4
  half_sqrt:       .single 0.5
.align 4
  one_sqrt:        .single 1.0
.align 4
  limit_sqrt:      .single 1e-5

@ Code Section
.section .text
.arm
.arch armv8-a

sqrt:
  VPUSH.F32 {S1-S5}
  LDR   R0, =one_sqrt
  VLDR  S1, [R0]         @ y_{k}

  LDR   R0, =half_sqrt
  VLDR  S2, [R0]         @ 1/2

  LDR   R0, =limit_sqrt
  VLDR  S3, [R0]         @ limit/tolerance (1e-5)

  sqrt_loop:
    VDIV.F32 S4, S0, S1  @ x / y_{k}
    VADD.F32 S4, S4, S1  @ y_{k} + x / y_{k}
    VMUL.F32 S4, S4, S2  @ 1/2 * (y_{k} + x / y_{k})

    VSUB.F32 S5, S4, S1
    VABS.F32 S5, S5      @ TODO: Call fabs()
    VMOV.F32 S1, S4
    VCMP.F32 S5, S3
    VMRS     APSR_nzcv, FPSCR
    BGT      sqrt_loop

  VMOV.F32 S0, S4
  VPOP.F32 {S1-S5}
  BX   LR
