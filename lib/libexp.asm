.include "./lib/libfactorial.asm"

@ Data Section
.data
.align 4
  zero_exp:       .single 0.0
.align 4
  one_exp:        .single 1.0
.align 4
  limit_exp:  .single 1e-5

@ Code Section
.section .text
.arm
.arch armv8-a

exp:
  VPUSH.F32 {S1-S10}
  @ S0 = x
  LDR  R0, =zero_exp
  VLDR S1, [R0]                 @ i = 0
  VLDR S2, [R0]                 @ ZERO constant
  VMOV.F32 S5, S0               @ Conservar valor de S0 em S5. S0 tornará-se parâmetro.
  LDR  R0, =limit_exp
  VLDR S7, [R0]                 @ S7 = limit/tolerance
  VMOV.F32 S8, S2               @ exp = 0 (somatório)
  LDR  R0, =one_exp
  VLDR S9, [R0]                 @ one constant

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
