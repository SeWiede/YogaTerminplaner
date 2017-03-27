	.file	"main.c"
	.text
.globl asmb
	.type	asmb, @function
asmb:
.LFB0:
	.cfi_startproc
	
	#x=rdi, n=rsi/rcx, y= rdx , *a = rcx/rsi	
	#frei: rax, r8, r9, r10, rsi
		
	#y saven 
	#mov %rcx, %rsi
	xchg %rsi, %rcx
	jrcxz end
	mov %rdx, %r8	

#	mov $0, %rdx
#	mov $0, %r10
	mov $0, %r11	
l:	
	mov 0(%rdi, %r11, 8), %rax
 	mul %r8
	mov %rdx, 8(%rsi, %r11, 8)
    add %rax, 0(%rsi, %r11, 8)
	adc $0, 8(%rsi, %r11, 8)
	#mov %rax, 0(%rsi, %r11, 8)
	add $1, %r11#%rsi
	#add $8, %rdi	
	loop l

#	mov %r10, 0(%rsi, %r11, 8)
end:
	ret

	.cfi_endproc
.LFE0:
	.size	asmb, .-asmb
	.ident	"GCC: (Debian 4.4.5-8) 4.4.5"
	.section	.note.GNU-stack,"",@progbits
