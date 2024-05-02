	.data
Header:	.space 56
Path:	.asciz "C:\\Users\\Adam\\Desktop\\asmProjekty\\juliaset\\example.bmp"
Error:	.asciz "Error with opening BMP File"
Error2:	.asciz "Error with writing to BMP File"
In1:	.asciz "Input real part of c:\n"
In2:	.asciz "Input imaginary part of c:\n"
	.text
	.globl main
main:
	li a7, 1024  # sys call for open file
	li a1, 0     # flag for reading
	la a0, Path
	ecall
	
	mv s0, a0    # move file decryptor to s0
	
	li t0, -1
	bne t0, s0, skiperror  # check if error with file
	
	li a7, 4
	la a0, Error
	ecall

skiperror:
	li a7, 4 
	la a0, In1
	ecall
	
	li a7, 5
	ecall
	mv s6, a0
	slli s6, s6, 12
	
	li a7, 4 
	la a0, In2
	ecall
	
	li a7, 5
	ecall
	mv s7, a0
	slli s7, s7, 12
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
	
	li t1, 0 # licznik pikseli w rzędzie
	li t2, 0 # licznik rzędów
#------------------------------------------------------------------------
calc_pixel_val:
	srai t4, s1, 1
	sub s8, t1, t4  # s8 = t1 - s1 // 2
	slli s8, s8, 13
	div s8, s8, t4 # s8 = Re z
	srai t4, s2, 1
	sub s9, t2, t4 # s9 = t2 - s2 // 2
	slli s9, s9, 13
	div s9, s9, t4 # s9 = Im z

	li t3, 40 # licznik iteracji
iterate:
	li t4, 4
	slli t4, t4, 12
	
	mul t5, s8, s8 # t5 = Re z ^ 2
	srai t5, t5, 12
	
	mul t6, s9, s9 # t6 = Im z ^ 2
	srai t6, t6, 12
	
	mul s9, s9, s8 # s9 = Re z * Im z
	srai s9, s9, 12
	slli s9, s9, 1 # s9 = 2 * Re z * Im z
	
	sub s8, t5, t6 # s8 = Re z ^ 2 - Im z ^ 2
	
	add s9, s9, s7 # s9 = Im z + Im c
	add s8, s8, s6 # s8 = Re z + Re c
	
	mul t5, s8, s8 # t5 = Re z ^ 2
	srai t5, t5, 12
	mul t6, s9, s9 # t6 = Im z ^ 2
	srai t6, t6, 12
	
	add t5, t5, t6 # t5 = Re z ^ 2 + Im z ^ 2 = r ^ 2
	
	bge t5, t4, not_in_set # if |r| > 2 <-> r ^ 2 > 4
	beqz t3, in_set
	addi t3, t3, -1
	b iterate
not_in_set:
	li t5, 0xFF
	sb t5, (t0)
	addi t0, t0, 1
	sb t5, (t0)
	addi t0, t0, 1
	sb t5, (t0)
	addi t0, t0, 1
	b checkrow
in_set:
	sb zero, (t0)
	addi t0, t0, 1
	sb zero, (t0)
	addi t0, t0, 1
	sb zero, (t0)
	addi t0, t0, 1
checkrow:
	addi t1, t1, 1
	li t3, 40
	bne t1, s1, calc_pixel_val
checkpadding:
	li t5, 3
	mul t6, s1, t5
	addi t5, t5, 1
	remu t5, t6, t5
	beqz t5, incrementrow
	li t6, 0
add_padding:
	sb zero, (t0)
	addi t0, t0, 1
	addi t6, t6, 1
	bne t5, t6, add_padding
incrementrow:
	li t1, 0
	addi t2, t2, 1
	bne t2, s2, calc_pixel_val
#------------------------------------------------------------------------
savebmp:
# save changes to bmp file ----------------------------------------------
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
