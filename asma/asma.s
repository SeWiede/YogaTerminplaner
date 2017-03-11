	.file	"main.c"
	.text
.globl asma
	.type	asma, @function
asma:
.LFB0:
	.cfi_startproc
	
		
	#speichert y (rdx wird von mul überschrieben) 
	mov %rdx, %r8	

	mov %rdi, %rax
	mul %r8 #r0 in rax, höhere 64 bit des Ergebnisses in rdx
		

	mov %rax, %r9	
	mov %rdx, %r10 #rdx zwichenspeichern
	
	mov %rsi, %rax 
	
	mul %r8
	add %r10, %rax #r1 in rax
	
	mov %rax, %r10

	adc $0, %rdx #r2 in rdx

	mov %rdx, %r11
	
	mov %r9, 0(%rcx)
	mov %r10, 8(%rcx)
	mov %r11, 16(%rcx)

	ret
	.cfi_endproc
.LFE0:
	.size	asma, .-asma
	.ident	"GCC: (Debian 4.4.5-8) 4.4.5"
	.section	.note.GNU-stack,"",@progbits
