.include "./lib/libfactorial.asm"

@ Data Section
.data
.align 4
  print: .asciz "Insert a value of x!: "
.align 4
  value:      .fill 3, 4, 0
.align 4
  scanfpoint: .asciz "%f"
.align 4
  result:     .asciz "x! = %f\n"

@ Code Section
.section .text
.global main
.arm
.arch armv8-a

main:
  PUSH {LR}
  LDR  R0, =print
  BL   printf
    
  LDR  R0, =scanfpoint
  LDR  R1, =value
  BL   scanf

  LDR  R1, =value
  VLDR S0, [R1]

  BL   factorial        @ factorial(S0)
  LDR  R0, =result      @ R0 = *result
  VCVT.F64.F32 D0, S0   @ D0 = (double) S0
  VMOV R1, R2, D0       @ R1, R2 <- D0
  BL   printf           @ printf(R0, R1.R2)

  POP  {LR}
  B    _exit

_exit:
  MOV R7, #1
  SVC #0 @ Invoke Syscall
