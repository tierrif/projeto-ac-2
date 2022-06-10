@ Data Section
.data
.balign 4
  fl: .single 2.56
.balign 4
  stri: .asciz "result: %f\n"

@ Code Section
.section .text
.global main
.arm
.arch armv8-a

main:
  LDR  R0, =fl
  VLDR S0, [R0, #1]
  VCVT.F64.F32 D0, S0   @ D0 = (double) S0
  VMOV R1, R2, D0       @ R1, R2 <- D0
  LDR  R0, =stri

  PUSH {LR}
  BL   printf
  POP  {LR}

  BX LR
  

_exit:
  MOV R7, #1
  SVC #0 @ Invoke Syscall
