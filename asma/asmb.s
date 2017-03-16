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
	mov %rdx, %r8	
	mov %rcx, %r11
	mov %rsi, %rcx
	
	mov $0, %rdx
	mov $0, %r10
	jecxz end
test:	
	mov 0(%rdi), %rax
 	mul %r8
    add %r10, %rax
	mov %rdx, %r10
	adc $0, %r10
	#rax = (0:16)
	#rdx = (16:32)
	mov %rax, 0(%r11)

	#lea 8(%r11, %r11, 0), %r11
	#lea 8(%rdi, %rdi, 0), %rdi
	inc %r11	
	inc %rdi	
	inc %r11	
	inc %rdi
	inc %r11	
	inc %rdi
	inc %r11	
	inc %rdi
	inc %r11	
	inc %rdi
	inc %r11	
	inc %rdi
	inc %r11	
	inc %rdi
	inc %r11	
	inc %rdi
	loop test

	mov %r10, 0(%r11)
end:
	ret

	.cfi_endproc
.LFE0:
	.size	asmb, .-asmb
	.ident	"GCC: (Debian 4.4.5-8) 4.4.5"
	.section	.note.GNU-stack,"",@progbits
