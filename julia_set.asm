	.data
Header:	.space 56
Path:	.asciz "C:\\Users\\Adam\\Desktop\\asmProjekty\\juliaset\\example.bmp"
Error:	.asciz "Error with opening BMP File"
	.text
	.globl main
main:
	li a7, 1024
	li a1, 0
	la a0, Path
	ecall
	
	mv s1, a0
	
	li t0, -1
	bne t0, s1, read_header
	
	li a7, 4
	la a0, Error
	ecall

read_header:
	li a7, 63
	mv a0, s1
	la a1, Header
	addi a1, a1, 2
	li a2, 54
	ecall