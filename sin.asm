@ Data Section
.data
.align 4
  zero:       .single 0.0
.align 4
  one:        .single 1.0
.balign 4
  minus_one:  .single -1.0
.balign 4
  two:        .single 2.0
.align 4
  sqrt_print: .asciz "Insert a value of sin(x): "
.align 4
  value:      .fill 3, 4, 0
.align 4
  scanfpoint: .asciz "%f"
.align 4
  result:     .asciz "Result: %f\n"

@ Code Section
.section .text
.global main
.arm
.arch armv8-a

main:
  PUSH {LR}
  LDR  R0, =sqrt_print
  BL   printf
    
  LDR  R0, =scanfpoint
  LDR  R1, =value
  BL   scanf

  LDR  R1, =value
  VLDR S0, [R1]

  BL   sin              @ sin(S0)
  LDR  R0, =result      @ R0 = *result
  VCVT.F64.F32 D0, S0   @ D0 = (double) S0
  VMOV R1, R2, D0       @ R1, R2 <- D0
  BL   printf           @ printf(R0, R1.R2)

  POP  {LR}
  B    _exit

sin:
  MOV  R0, #0                @ n
  LDR  R1, =minus_one
  VLDR S1, [R1]              @ -1.0
  sin_loop:
    @ TODO: (-1)^n

    ADD      R0, #1
    CMP      R0, #30         @ número máximo de iterações (TODO: usar critério de paragem)
    BLE      sin_loop
  BX   LR

factorial:
  VPUSH.F32 {S1-S5}

  LDR  R0, =zero
  VLDR S1, [R0]                  @ S1 começa em 0 mas incrementa.
  VLDR S4, [R0]                  @ S4 é uma constante de 0.
  LDR  R0, =one
  VLDR S2, [R0]                  @ S2 é uma constante de 1.

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
  VPOP.F32 {S1-S5}

  BX   LR


_exit:
  MOV R7, #1
  SVC #0 @ Invoke Syscall
