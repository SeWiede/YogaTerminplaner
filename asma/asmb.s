	.file	"main.c"
	.text
.globl asmb
	.type	asmb, @function
asmb:
.LFB0:
	.cfi_startproc
	
	#x=rdi, n=rsi/rcx, y= rdx , *a = rcx/r11	
	#frei: rax, r8, r9, r10, r11
		
	#y saven 
	#mov %rdx, %r8	
	#mov %rcx, %r11
	#mov %rsi, %rcx
	

test:	#mov 0(%rdi), %rax
	#mul %r8 #r0 = x0*y (0)
	#rdx (1)	

#	mov %rax, %r9
	#mov %rax, 0(%r11)	
	#mov %rdx, %r10 #(1) speichern

	
	#mov %rsi, %rax #x1 
	
	#mul %r8
	#rax = x1*y (0) rdx (1)
	#add %r10, %rax
	
	#mov %rax, %r10 #r10 = r1
	#mov %r10, 8(%r11)

	#adc $0, %rdx

	#mov %rdx, 16(%r11)
	
	#add 24, %r11
	#add 24, %rdi
#	loop test
	#mov %r11, 16(%rcx)


	.cfi_endproc
.LFE0:
	.size	asmb, .-asmb
	.ident	"GCC: (Debian 4.4.5-8) 4.4.5"
	.section	.note.GNU-stack,"",@progbits
