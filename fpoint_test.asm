@ Data Section
.data
.balign 4
  fl: .single 2.56

@ Code Section
.section .text
.global main
.arm
.arch armv8-a

main:
  LDR  R0, =fl
  VLDR S0, [R0]

_exit:
  MOV R7, #1
  SVC #0 @ Invoke Syscall
