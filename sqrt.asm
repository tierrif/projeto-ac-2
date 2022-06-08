@ Data Section
.data
.align 4
  half:       .single 0.5
.align 4
  one:        .single 1.0
.align 4
  limit:      .single 1e-5

.align 4
  sqrt_print: .asciz "Insert a value of sqrt(x): "
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

  BL   sqrt             @ sqrt(S0)
  LDR  R0, =result      @ R0 = *result
  VCVT.F64.F32 D0, S0   @ D0 = (double) S0
  VMOV R1, R2, D0       @ R1, R2 <- D0
  BL   printf           @ printf(R0, R1.R2)

  POP  {LR}
  B    _exit

sqrt:
  LDR   R0, =one
  VLDR  S1, [R0]         @ y_{k}

  LDR   R0, =half
  VLDR  S2, [R0]         @ 1/2

  LDR   R0, =limit
  VLDR  S3, [R0]         @ limit/tolerance (1e-5)

  sqrt_loop:
    VDIV.F32 S4, S0, S1 @ x / y_{k}
    VADD.F32 S4, S4, S1 @ y_{k} + x / y_{k}
    VMUL.F32 S4, S4, S2 @ 1/2 * (y_{k} + x / y_{k})

    VSUB.F32 S5, S4, S1
    VABS.F32 S5, S5     @ TODO: Call fabs()
    VMOV.F32 S1, S4
    VCMP.F32 S5, S3
    VMRS     APSR_nzcv, FPSCR
    BGT      sqrt_loop

  VMOV.F32 S0, S4
  BX   LR


_exit:
  MOV R7, #1
  SVC #0 @ Invoke Syscall
