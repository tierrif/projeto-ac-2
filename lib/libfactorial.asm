@ Data Section
.data
.align 4
  zero_factorial: .single 0.0
.align 4
  one_factorial:  .single 1.0

@ Code Section
.section .text
.arm
.arch armv8-a

factorial:
  VPUSH.F32 {S1-S5}

  LDR  R0, =zero_factorial
  VLDR S1, [R0]                  @ S1 começa em 0 mas incrementa.
  VLDR S4, [R0]                  @ S4 é uma constante de 0.
  LDR  R0, =one_factorial
  VLDR S2, [R0]                  @ S2 é uma constante de 1.

  VCMP.F32   S0, S2
  VMRS       APSR_nzcv, FPSCR
  VMOVEQ.F32 S0, S2
  BEQ        factorial_end
  VCMP.F32   S0, S4
  VMRS       APSR_nzcv, FPSCR
  VMOVEQ     S0, S2
  BEQ        factorial_end

  factorial_loop:
    VMOV.F32 S3, S1              @ S3 = i
    VMOV.F32 S5, S3              @ Criar cópia de S3 para S5. S5 é out.
    VSUB.F32 S3, S2              @ S3 -= 1.0
    factorial_loop_2:
      VMUL.F32 S5, S3            @ S5 *= S3
      VSUB.F32 S3, S2            @ S3 -= 1.0 (decrementa, i--)
      VCMP.F32 S3, S4            @ S3 > 0
      VMRS     APSR_nzcv, FPSCR
      BGT      factorial_loop_2
    VCMP.F32 S1, S0              @ i < range 
    VADD.F32 S1, S2              @ S1 += 1.0
    VMRS     APSR_nzcv, FPSCR
    BLT      factorial_loop
  VMOV.F32 S0, S5
  factorial_end:
  VPOP.F32 {S1-S5}

  BX   LR
