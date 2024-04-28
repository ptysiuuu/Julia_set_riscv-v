	.data
Header:	.space 56
Path:	.asciz "C:\\Users\\Adam\\Desktop\\asmProjekty\\juliaset\\example.bmp"
Error:	.asciz "Error with opening BMP File"
Error2:	.asciz "Error with writing to BMP File"
	.text
	.globl main
main:
	li a7, 1024  # sys call for open file
	li a1, 0     # flag for reading
	la a0, Path
	ecall
	
	mv s0, a0    # move file decryptor to s0
	
	li t0, -1
	bne t0, s0, readbmp  # check if error with file
	
	li a7, 4
	la a0, Error
	ecall

readbmp:
	li a7, 63   # sys call for reading a decryptor
	mv a0, s0
	la a1, Header
	addi a1, a1, 2  # move from signature
	li a2, 54
	ecall
	
	lw s1, 18(a1)  # bmp file width in s1
	lw s2, 22(a1)  # bmp file height in s2
	lw s3, 2(a1)   # bmp file size in s3
	lw s4, 10(a1)  # bmp file offset to pixel array
	sub s5, s3, s4 # pixel array size in s5
	
	li a7, 9  # allocate heap memory
	mv a0, s5
	ecall
	
	mv s11, a0
	mv t0, a0 # address of heap memory allocated
	
	li a7, 63
	mv a0, s0
	mv a1, t0
	mv a2, s5
	ecall  # read pixel array to allocated heap memory in (t0)
	
	li a7, 57
	mv a0, s0
	ecall
	
	li t1, 0
	li t2, 0
	li t3, 0
	li t4, 3
#------------------------------------------------------------------------
colorpixelrow:
# change pixels to black ------------------------------------------------
	sb zero, (t0)
	addi t0, t0, 1
	addi t3, t3, 1
	bne t3, t4, colorpixelrow
	li t3, 0
	addi t1, t1, 1
	bne t1, s1, colorpixelrow
	li t1, 0
calcpadding:
# add padding -----------------------------------------------------------
	mul t5, s1, t4
	addi t4, t4, 1
	remu t5, t5, t4
	bnez t5, addpadding
	li t4, 3
	addi t2, t2, 1
	bne t2, s2, colorpixelrow
	b savebmp
addpadding:
	sb zero, (t0)
	addi t0, t0, 1
	addi t1, t1, 1
	bne t1, t5, addpadding
	li t4, 3
	addi t2, t2, 1
	li t1, 0
	bne t2, s2, colorpixelrow
#------------------------------------------------------------------------
savebmp:
# save changes t0 bmp file ----------------------------------------------
	li a7, 1024
	li a1, 1
	la a0, Path
	ecall
	mv s0, a0
	
	li t0, -1
	bne s0, t0, saveheader
	li a7, 4
	la a0, Error2
	ecall

saveheader:
	li a7, 64
	mv a0, s0
	la a1, Header
	addi a1, a1, 2
	li a2, 54
	ecall
	
	li a7, 64
	mv a0, s0
	mv a1, s11
	mv a2, s5
	ecall
	
	li a7, 57
	mv a0, s0
	ecall
#------------------------------------------------------------------------
end:
	li a7, 10
	ecall
