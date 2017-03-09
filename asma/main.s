	.file	"main.c"
	.text
.globl asma
	.type	asma, @function
asma:
.LFB0:
	.cfi_startproc
	
	#x0=rdi, x1=rsi, y= rdx , *a = rcx	
	#frei: rax, r8, r9, r10, r11
		
	#y saven 
	mov %rdx, %r8	

	mov %rdi, %rax
	mul %r8 #r0 = x0*y (0)
	#rdx (1)	

	mov %rax, %r9	
	mov %rdx, %r10 #(1) speichern
	
	mov %rsi, %rax #x1 
	
	mul %r8
	#rax = x1*y (0) rdx (1)
	add %r10, %rax
	
	mov %rax, %r10 #r10 = r1

	adc $0, %rdx

	mov %rdx, %r11
	
	mov %r9, 0(%rcx)
	mov %r10, 8(%rcx)
	mov %r11, 16(%rcx)


	.cfi_endproc
.LFE0:
	.size	asma, .-asma
	.ident	"GCC: (Debian 4.4.5-8) 4.4.5"
	.section	.note.GNU-stack,"",@progbits
