@ Data Section
.data
.align 4
  zero:       .single 0.0
.align 4
  one_print:  .asciz "Insert the mantissa: "
.align 4
  two_print:  .asciz "Insert the exponent: "
.align 4
  half:       .single 0.5
.align 4
  value:      .fill 3, 4, 0
.align 4
  value2:     .fill 3, 4, 0
.align 4
  limit:      .single 1e-5
.align 4
  scanfpoint: .asciz "%f"
.align 4
  result:     .asciz "x * 2^y: %f\n"
.align 4
  one:        .single 1.0
.align 4
  two:        .single 2.0
.align 4
  thousand:   .single 1000.0

@ Code Section
.section .text
.global main
.arm
.arch armv8-a

main:
  PUSH {LR}
  LDR  R0, =one_print
  BL   printf
    
  LDR  R0, =scanfpoint
  LDR  R1, =value
  BL   scanf

  LDR  R1, =value
  VLDR S0, [R1]

  LDR  R0, =two_print
  BL   printf
    
  LDR  R0, =scanfpoint
  LDR  R1, =value2
  BL   scanf

  LDR  R1, =value
  VLDR S0, [R1]
  LDR  R1, =value2
  VLDR S1, [R1]

  BL   ldexp            @ ldexp(S0, S1)
  LDR  R0, =result      @ R0 = *result
  VCVT.F64.F32 D0, S0   @ D0 = (double) S0
  VMOV R1, R2, D0       @ R1, R2 <- D0
  BL   printf           @ printf(R0, R1.R2)

  POP  {LR}
  B    _exit

ldexp:
  VPUSH.F32 {S2}
  VMOV.F32 S2, S0
  LDR  R0, =two
  VLDR S0, [R0]

  PUSH {LR}
  BL   pow
  POP  {LR}

  VMUL.F32 S0, S0, S2
  VPOP.F32 {S2}
  BX   LR

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

exp:
  VPUSH.F32 {S1-S10}
  @ S0 = x
  LDR  R0, =zero
  VLDR S1, [R0]                 @ i = 0
  VLDR S2, [R0]                 @ ZERO constant
  VMOV.F32 S5, S0               @ Conservar valor de S0 em S5. S0 tornará-se parâmetro.
  LDR  R0, =limit
  VLDR S7, [R0]                 @ S7 = limit/tolerance
  VMOV.F32 S8, S2               @ exp = 0 (somatório)
  LDR  R0, =one
  VLDR S9, [R0]                 @ ONE constant

  exp_loop:
    VCMP.F32   S1, S2
    VMRS       APSR_nzcv, FPSCR
    VADDEQ.F32 S8, S9
    VADDEQ.F32 S1, S9
    BEQ        exp_loop

    VCMP.F32   S1, S9
    VMRS       APSR_nzcv, FPSCR
    VADDEQ.F32 S8, S5
    VADDEQ.F32 S1, S9
    BEQ        exp_loop

    VMOV.F32 S3, S2
    VMOV.F32 S4, S5
    exp_pow_loop:
      VMUL.F32 S4, S5

      VSUB.F32 S10, S1, S9
      VSUB.F32 S10, S9
      
      VCMP.F32 S3, S10
      VMRS     APSR_nzcv, FPSCR
      VADD.F32 S3, S9
      BLT      exp_pow_loop

    @ factorial() call
    VMOV.F32 S0, S1
    PUSH     {LR}
    BL       factorial          @ S0 = i!
    POP      {LR}
    @ end factorial() call

    exp_skip_loop_start:

    VDIV.F32 S6, S4, S0         @ S6 = x^i/i!
    VCMP.F32 S6, S7             @ x^i/i! <= limit/tolerance?
    VADD.F32 S8, S6
    VMRS     APSR_nzcv, FPSCR
    BLE      exp_loop_end

    VADD.F32 S1, S9
    B        exp_loop
  exp_loop_end:
  VMOV.F32 S0, S8
  VPOP.F32 {S1-S10}
    
  BX   LR

factorial:
  VPUSH.F32 {S1-S5}

  LDR  R0, =zero
  VLDR S1, [R0]                  @ S1 começa em 0 mas incrementa.
  VLDR S4, [R0]                  @ S4 é uma constante de 0.
  LDR  R0, =one
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

_exit:
  MOV R7, #1
  SVC #0 @ Invoke Syscall
