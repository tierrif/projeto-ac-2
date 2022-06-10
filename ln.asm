@ Data Section
.data
.align 4
  zero:       .single 0.0
.align 4
  one:        .single 1.0
.align 4
  two:        .single 2.0
.align 4
  thousand:   .single 1000.0
.align 4
  epsilon:    .single 2.7182818284
.align 4
  pi:         .single 3.14159265
.align 4
  limit:      .single 1e-5
.align 4
  sqrt_print: .asciz "Insert a value of ln(x): "
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

  BL   ln               @ ln(S0)
  LDR  R0, =result      @ R0 = *result
  VCVT.F64.F32 D0, S0   @ D0 = (double) S0
  VMOV R1, R2, D0       @ R1, R2 <- D0
  BL   printf           @ printf(R0, (float)(R1, R2))

  POP  {LR}
  B    _exit

ln:
  VPUSH.F32 {S1-S13}
  @ S0 = n
  LDR  R0, =zero
  VLDR S1, [R0]        @ num = 0
  VMOV.F32 S2, S1      @ mul = 0
  VMOV.F32 S3, S1      @ cal = 0
  VMOV.F32 S4, S1      @ sum = 0

  VMOV.F32 S11, S1     @ S11 = 0 constant

  LDR  R0, =thousand 
  VLDR S9, [R0]        @ S9 = 1000 constant
  LDR  R0, =two
  VLDR S10, [R0]       @ S10 = 2 constant

  LDR  R0, =one
  VLDR S7, [R0]        @ S7 = 1 constant
  VMOV.F32 S8, S7      @ i = 1

  VSUB.F32 S5, S0, S7
  VADD.F32 S6, S0, S7
  VDIV.F32 S1, S5, S6

  ln_loop:
    VMUL.F32 S2, S10, S8      @ mul = 2 * i
    VSUB.F32 S2, S7           @ mul -= 1

    VCMP.F32 S2, S7           @ mul == 1
    VMRS APSR_nzcv, FPSCR
    VADDEQ.F32 S4, S1
    BEQ  ln_pow_loop_end

    VMOV.F32 S12, S11         @ j = 0
    VMOV.F32 S3, S1
    ln_pow_loop:
      VMUL.F32 S3, S1

      VSUB.F32 S13, S2, S10

      VCMP.F32 S12, S13        @ j <= mul
      VMRS APSR_nzcv, FPSCR
      VADD.F32 S12, S7        @ j++
      BLT  ln_pow_loop

    @ Instruções pós-iteração.
    VDIV.F32 S3, S3, S2
    VADD.F32 S4, S3
    ln_pow_loop_end:

    VCMP.F32 S8, S9           @ i <= 1000
    VMRS APSR_nzcv, FPSCR
    VADD.F32 S8, S7           @ i++
  BLE  ln_loop

  VMUL.F32 S4, S4, S10
  VMOV.F32 S0, S4

  VPOP.F32 {S1-S13}

  BX       LR

_exit:
  MOV R7, #1
  SVC #0 @ Invoke Syscall
