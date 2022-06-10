/*
 * Instituto Politécnico de Beja
 * Escola Superior de Tecnologia e Gestão
 * Engenharia Informática - Arquitetura de Computadores
 * Projeto de Programação em Assembly para a Arquiterura ARM 2 0.1
 *
 * Tierri Ferreira, 22897
 * André Azevedo, 22483
 */

@ Data section
.data
.balign 4
  menu:    .asciz "\n------------------------------------------\n                   Menu \n------------------------------------------\na. acosh\nb. asinh\nc. atanh\nd. cosh\ne. exp\nf. fabs\ng. factorial\nh. hypot\ni. ldexp\nj. ln\nk. log10\nl. pow\nm. sinh\nn. sqrt\no. tanh\nSelect option: "
.balign 4
  string:  .asciz "%s"
.balign 4
  char:    .asciz "%c"
.balign 4
  test:    .fill 64, 1, 0
.balign 4
  invalid: .asciz "Invalid option.\nTry again: "
.balign 4
  run:     .asciz "./run.sh "

.balign 4
  acosh: .asciz "acosh"
.balign 4
  asinh: .asciz "asinh"
.balign 4
  atanh: .asciz "atanh"
.balign 4
  cosh: .asciz "cosh"
.balign 4
  exp: .asciz "exp"
.balign 4
  fabs: .asciz "fabs"
.balign 4
  factorial: .asciz "factorial"
.balign 4
  hypot: .asciz "hypot"
.balign 4
  ldexp: .asciz "ldexp"
.balign 4
  ln: .asciz "ln"
.balign 4
  log10: .asciz "log10"
.balign 4
  pow: .asciz "pow"
.balign 4
  sinh: .asciz "sinh"
.balign 4
  sqrt: .asciz "sqrt"
.balign 4
  tanh: .asciz "tanh"

.global scanf
.global printf
.global system
.global strcat

.section .text
.global main
.arm

main:
  LDR   R0, =menu            @ Carregar string do menu.
  BL    printf               @ Mostar menu.
  B     skip_repeat          @ Não executar parte de input inválido.
repeat:
  LDR   R0, =invalid         @ Quando o utilizador usa input inválido, mostrar mensagem.
  BL    printf               @ Chamar printf().
skip_repeat:
  LDR   R0, =string          @ Carregar string com %s para scanf().
  LDR   R1, =test            @ Carregar string de destino.
  BL    scanf                @ Chamar scanf() e pedir input ao utilizador.

  LDR   R2, =test            @ Carregar string de destino com input.
  LDRB  R3, [R2, #0]         @ Carregar primeiro caracter, porque apenas queremos um caracter.

  PUSH  {R0-R1, LR}          @ Reservar R0, R1 e LR.
  MOV   R0, R3               @ Colocar char no primeiro parâmetro.
  BL    _functionNameByIndex @ Obter nome da função obtida pelo menu.
  MOV   R3, R0               @ Retomar o valor retornado para R3.
  POP   {R0-R1, LR}          @ Retomar a valores originais dos registos.

  CMP   R3, #0               @ Verificar se o nome da função é nulo.
  BEQ   repeat               @ Se sim, o input foi inválido. Repetir.

  LDR   R0, =run             @ Carregar string com comando ./run.
  MOV   R1, R3               @ Colocar nome da função em segundo parâmetro.
  BL    strcat               @ Concatenar com strcat().

  BL    system               @ Executar o comando, executando o ficheiro respetivo da função.

  B     _exit                @ Pedir ao SO para sair deste programa.

_functionNameByIndex:
  @ Conservar R0 em R1.
  MOV   R1, R0
  @ Retornar nulo por defeito.
  MOV   R0, #0

  @ Obter nome da função pela letra do menu.
  CMP R1, #'a'
  LDREQ R0, =acosh
  CMP R1, #'b'
  LDREQ R0, =asinh
  CMP R1, #'c'
  LDREQ R0, =atanh
  CMP R1, #'d'
  LDREQ R0, =cosh
  CMP R1, #'e'
  LDREQ R0, =exp
  CMP R1, #'f'
  LDREQ R0, =fabs
  CMP R1, #'g'
  LDREQ R0, =factorial
  CMP R1, #'h'
  LDREQ R0, =hypot
  CMP R1, #'i'
  LDREQ R0, =ldexp
  CMP R1, #'j'
  LDREQ R0, =ln
  CMP R1, #'k'
  LDREQ R0, =log10
  CMP R1, #'l'
  LDREQ R0, =pow
  CMP R1, #'m'
  LDREQ R0, =sinh
  CMP R1, #'n'
  LDREQ R0, =sqrt
  CMP R1, #'o'
  LDREQ R0, =tanh
  @ return;
  BX    LR

_exit:
  MOV R7, #1
  SVC #0     @ Invoke Syscall
