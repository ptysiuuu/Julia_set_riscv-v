#--------Autor:  Adam Szostek--------------------------------------------------------------------------
#--------Działanie programu: Generacja Fraktalu Julii w istniejącym pliku BMP dla zadanych parametrów c.
	.data
Header:	.space 56
Path:	.asciz "C:\\Users\\Adam\\Desktop\\asmProjekty\\juliaset\\julia.bmp"
Error:	.asciz "Error with opening BMP File"
Error2:	.asciz "Error with writing to BMP File"
In1:	.asciz "Input real part of c in fixed-point format (eg. 1250 = 1.250):\n"
In2:	.asciz "Input imaginary part of c in fixed-point format (eg. 1250 = 1.250):\n"
	.text
	.globl main
main:
	li a7, 1024  # wywołanie systemowe dla otworzenia pliku
	li a1, 0     # flag for reading
	la a0, Path  # ścieżka do pilku
	ecall
	
	mv s0, a0    # przenieś deskryptor pliku do s0
	
	li t0, -1
	bne t0, s0, skiperror  # sprawdź czy nastąpił błąd z otworzeniem pliku
	
	li a7, 4
	la a0, Error
	ecall # wyświetl komunikat o błędzie
	
	li a7, 10
	ecall
skiperror: # nie nastąpił błąd, działaj dalej
	li a7, 4 
	la a0, In1
	ecall # pobierz Re c
	
	li a7, 5
	ecall
	mv s6, a0
	slli s6, s6, 2 # załaduj Re c do s6 i przesuń do odpowiedniego formatu fixed-point
	
	li a7, 4 
	la a0, In2
	ecall # pobierz Im c
	
	li a7, 5
	ecall
	mv s7, a0
	slli s7, s7, 2 # załaduj Im c do s7 i przesuń do odpowiedniego formatu fixed-point
readbmp:
	li a7, 63   # wywołanie systemowe dla czytania z deskryptora
	mv a0, s0
	la a1, Header
	addi a1, a1, 2  # odsuń od oznaczenia pliku
	li a2, 54
	ecall # przeczytaj nagłowek do bufora Header
	
	lw s1, 18(a1)  # szerokość pliku BMP w s1
	lw s2, 22(a1)  # wysokość pliku BMP w s2
	lw s3, 2(a1)   # wielkość pliku BMP w s3
	lw s4, 10(a1)  # offset do tablicy pikseli w s4
	sub s5, s3, s4 # wielkość tablicy pikseli w s5
	
	li a7, 9  # alokacja pamięci na stercie
	mv a0, s5
	ecall
	
	mv s11, a0 # zapisz w s11 adres początku zaalokowanej pamięci na stercie, aby później zapisać tablicę pikseli
	mv t0, a0 # adres zaalokowanej pamięci na stercie
	
	li a7, 63
	mv a0, s0
	mv a1, t0
	mv a2, s5
	ecall  # przeczytaj tablicę pikseli do adresu w (t0)
	
	li a7, 57
	mv a0, s0
	ecall # zamknij czytany plik BMP
	
	li t1, 0 # licznik pikseli w rzędzie
	li t2, 0 # licznik rzędów

#-----Funkcje działające na pikselach------------------------------------
#------------------------------------------------------------------------
calc_pixel_val:
	srai t4, s1, 1 # t4 = width / 2 -> wartość "wysunięć" od zera gdyby podziałka była co jeden piksel
	sub s8, t1, t4  # s8 = t1 - width // 2 -> wartość "wysunięcia" dla aktualnego piksela gdyby podziałka była co jeden piksel
	slli s8, s8, 13 # przesunięcie do odp. fixed-point i s8 = s8 * 2
	div s8, s8, t4 # s8 = Re z -> 4/width (podziałka dla układu wsp. od -2 do 2) * wartość punktu dla aktualnego piksela gdyby podziałka była co jeden piksel
	srai t4, s2, 1 # t4 = height / 2 -> wartość "wysunięć" od zera gdyby podziałka była co jeden piksel
	sub s9, t2, t4 # s9 = t2 - height // 2 -> wartość "wysunięcia" dla aktualnego piksela gdyby podziałka była co jeden piksel
	slli s9, s9, 13 # przesunięcie do odp. fixed-point i s8 = s8 * 2
	div s9, s9, t4 # s8 = Im z -> 4/width (podziałka dla układu wsp. od -2 do 2) * wartość punktu dla aktualnego piksela gdyby podziałka była co jeden piksel

	li t3, 40 # licznik iteracji
iterate:
	li t4, 4
	slli t4, t4, 12 # przesuń 4 do odpowiedniego formatu fixed-point
	
	mul t5, s8, s8 # t5 = Re z ^ 2
	srai t5, t5, 12 # korekta mnożenia w fixed-point
	
	mul t6, s9, s9 # t6 = Im z ^ 2
	srai t6, t6, 12 # korekta mnożenia w fixed-point
	
	mul s9, s9, s8 # s9 = Re z * Im z
	srai s9, s9, 11 # korekta mnożenia w fixed-point, s9 = 2 * Re z * Im z
	
	sub s8, t5, t6 # s8 = Re z ^ 2 - Im z ^ 2
	
	add s9, s9, s7 # s9 = Im z + Im c
	add s8, s8, s6 # s8 = Re z + Re c
	
	mul t5, s8, s8 # t5 = Re z ^ 2
	srai t5, t5, 12 # korekta mnożenia w fixed-point
	mul t6, s9, s9 # t6 = Im z ^ 2
	srai t6, t6, 12 # korekta mnożenia w fixed-point
	
	add t5, t5, t6 # t5 = Re z ^ 2 + Im z ^ 2 = r ^ 2
	
	bge t5, t4, not_in_set # if |r| > 2 <-> r ^ 2 > 4
	addi t3, t3, -1 # dekrementacja licznika iteracji
	bnez t3, iterate # iteration = 40
in_set: # pokoloruj piksel na czarno 
	sb zero, (t0)
	addi t0, t0, 1
	sb zero, (t0)
	addi t0, t0, 1
	sb zero, (t0)
	addi t0, t0, 1
	b check_row
not_in_set: # pokoloruj piksel na biało
	li t5, 0xFF
	sb t5, (t0)
	addi t0, t0, 1
	sb t5, (t0)
	addi t0, t0, 1
	sb t5, (t0)
	addi t0, t0, 1
check_row: # sprawdź czy koniec rzędu pikseli
	addi t1, t1, 1
	li t3, 40
	bne t1, s1, calc_pixel_val
check_padding: # sprawdź czy potrzebny jest padding
	li t5, 3
	mul t6, s1, t5
	addi t5, t5, 1
	remu t5, t6, t5
	beqz t5, increment_row # padding nie potrzebny
	li t6, 0 # padding potrzebny
add_padding: # dodaj padding na koniec rzędu
	sb zero, (t0)
	addi t0, t0, 1
	addi t6, t6, 1
	bne t5, t6, add_padding
increment_row: # koniec rzędu, zinkrementuj wartość licznika wysokości/rzędów
	li t1, 0
	addi t2, t2, 1
	bne t2, s2, calc_pixel_val
#------------------------------------------------------------------------
savebmp:
#-----Zapisz zmiany do pliku BMP-----------------------------------------
	li a7, 1024
	li a1, 1
	la a0, Path
	ecall # otwórz plik BMP do zapisu
	mv s0, a0 # deskryptor w s0
	
	li t0, -1
	bne s0, t0, saveheader # nie ma błędu w otworzeniu pliku

	li a7, 4
	la a0, Error2
	ecall # wyświetl komunikat błędu
	
	li a7, 10
	ecall # zakończ program w związku z błędem
saveheader: # zapisz nagłówek
	li a7, 64 # zapisywanie do pliku
	mv a0, s0 # deskryptor pliku
	la a1, Header
	addi a1, a1, 2 # dorównanie do sygnatury
	li a2, 54
	ecall
	
	li a7, 64 # zapisywanie do pliku
	mv a0, s0 # deskryptor pliku
	mv a1, s11 # adres tablicy pikseli na stercie
	mv a2, s5 # wielkość tablicy pikseli
	ecall # zapisanie tablicy pikseli
	
	li a7, 57
	mv a0, s0
	ecall # zamknięcie pliku
#------------------------------------------------------------------------
end:
	li a7, 10
	ecall # koniec programu
