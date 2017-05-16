#ifndef UTIL_H
#define UITL_H


enum regs {rax = 0, rcx, rdx, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, rbx, rbp, rsp};


typedef enum type{TYP_ANY = 0, VARIABLE = 1, LABEL = 2} Type;
typedef enum occ{OCC_ANY =0, USE =1, DEF=2} Occurence;

struct list {
	char *name;
	Type typ;
	Occurence occ;
 	struct list *next;
};
typedef struct list Name;
typedef Name * NameList;


void populateParameters(NameList par);

int checkRegister(int regno);

char *toRegister(int regno);
int isCalleeSaved(int regno);

int getreg(void);
int getregForVariable(char *var);

void freeReg(int regno);
void freeAllRegs();

#endif
