@ Data Section
.data
.align 4
  zero:       .single 0.0
.align 4
  sqrt_print: .asciz "Insert a value of fabs(x): "
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

  BL   fabs             @ fabs(S0)
  LDR  R0, =result      @ R0 = *result
  VCVT.F64.F32 D0, S0   @ D0 = (double) S0
  VMOV R1, R2, D0       @ R1, R2 <- D0
  BL   printf           @ printf(R0, R1.R2)

  POP  {LR}
  B    _exit

fabs:
  VPUSH      {S1}
  PUSH       {R0}

  LDR        R0, =zero
  VLDR       S1, [R0]
  VCMP.F32   S0, S1
  VMRS       APSR_nzcv, FPSCR
  BGE        fabs_end

  VNEG.F32   S0, S0           @ Negar os bits do valor binário de S0 de modo a se tornar positivo.

  fabs_end:

  VPOP.F32   {S1}
  POP        {R0}

  BX   LR


_exit:
  MOV R7, #1
  SVC #0 @ Invoke Syscall
