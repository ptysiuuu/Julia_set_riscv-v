	.data
Header:	.space 56
Path:	.asciz "C:\\Users\\Adam\\Desktop\\asmProjekty\\juliaset\\example.bmp"
Error:	.asciz "Error with opening BMP File"
	.text
	.globl main
main:
	li a7, 1024  # sys call for open file
	li a1, 1     # flag dor writing
	la a0, Path
	ecall
	
	mv s0, a0    # move file decryptor to s0
	
	li t0, -1
	bne t0, s0, read_header  # check if error with file
	
	li a7, 4
	la a0, Error
	ecall

read_header:
	li a7, 63   # sys call for reading a decryptor
	mv a0, s0
	la a1, Header
	addi a1, a1, 2  # move from signature
	li a2, 54
	ecall
	
	lw s1, 18(a1)  # bmp file width in s1
	lw s2, 22(a1)  # bmp file height in s2
	lw s3, 2(a1)   # bmp file size in s3
	lw s4, 10(a1)  # bmp file offset ro pixel array
	sub s5, s3, s4 # pixel array size in s5
	
	li a7, 9  # allocate heap memory
	mv a0, s5
	ecall
	
	mv t0, a0 # address of heap memory allocated
	
	li a7, 63
	mv a0, s0
	mv a1, t0
	mv a2, s5
	ecall  # read pixel array to allocated heap memory in (t0)
	
	
	