
#include "util.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct parameters{
	char *parname;
	int regno;
}parameters[6];

int registers[15];
int parnums[] = {4, 3, 2, 1, 5, 6};

enum regs {rax = 0, rcx, rdx, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, rbx, rbp, rsp};

void populateParameters(NameList par){
	int i;
	for(i=0;par != NULL && i < 6;i++){
		//rdi, rsi, rdx, rcx, r8, r9
		if(par->name != NULL) {
			parameters[i].parname = par->name;
			parameters[i].regno = parnums[i];
			registers[parnums[i]] = 1;
			par = par->next;
		}
	}	
}

int checkRegister(int regno){
	return registers[regno] ==0;
}

char *toRegister(int regno) {
	switch(regno) {
		case rax: return "%rax";
		case rbx: return "%rbx";
		case rcx: return "%rcx";
		case rdx: return "%rdx";
		case rsp: return "%rsp";
		case rsi: return "%rsi";
		case rdi: return "%rdi";
		case r8: return "%r8";
		case r9: return "%r9";
		case r10: return "%r10";
		case r11: return "%r11";
		case r12: return "%r12";
		case r13: return "%r13";
		case r14: return "%r14";
		case r15: return "%r15";
		case rbp: return "%rbp";
	}
}

int isCalleeSaved(int regno){
	switch(regno) {
		case rax: return 0;
		case rbx: return 1;
		case rcx: return 0;
		case rdx: return 0;
		case rsp: return 1;
		case rsi: return 0;
		case rdi: return 0;
		case r8: return 0;
		case r9: return 0;
		case r10: return 0;
		case r11: return 0;
		case r12: return 1;
		case r13: return 1;
		case r14: return 1;
		case r15: return 1;
		case rbp: return 1;
	}

}


int getreg(void){
	int i=0;
	for(i; i<15; i++) {
		if(registers[i] == 0) {
			registers[i] = 1;
			if(isCalleeSaved(i) == 1)
				printf("\tpush %s\n", toRegister(i));
			return i;
		}
	}
	printf("out of registers \n");
	exit(4);
}

void freeReg(int regno) {
	if(registers[regno] == 1) {
		if(isCalleeSaved(regno) == 1)
			printf("\tpop %s\n", toRegister(regno));
		registers[regno] = 0;
	}
	else {
		printf("Register already freed");
		exit(4);
	}
}

void freeAllRegs(){
	int i;
	for(i=14; i >=0 ;i--){
		if(registers[i] == 1 && isCalleeSaved(i) == 1)
			printf("\tpop %s\n", toRegister(i));
		registers[i] = 0;
	}
}

int getregForVariable(char *var) {
	int i;
	for(i=0;i<6;i++){
		if(parameters[i].parname == NULL)
			exit(4);
		if(strcmp(var, parameters[i].parname)==0)
			return parameters[i].regno;	
	}
	exit(4);
}

