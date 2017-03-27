#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <inttypes.h>

void print(uint8_t *a){
	for(int i =23; i>=16; i--){
		printf("%x", a[i]);
	}

	printf(" ");

	for(int i =15; i>=8; i--){
		printf("%x", a[i]);
	}

	printf(" ");

	for(int i =7; i>=0; i--){
		printf("%x", a[i]);
	}

	printf("\n");

}

void printH(uint64_t *a){
for(int i=3;i>=0;i--)
	printf("%"PRIx64" ", a[i]);
printf("\n");

}

int main(){
uint8_t a[24];
uint64_t b[8];

for(int i=0;i<24;i++)
{
	a[i] =0;
}

for(int i=0; i<4; i++) {
	b[i] = 0;
}

long long out=0;

unsigned long x1 = 0xffffffffffffffff;
unsigned long x2 = x1;
unsigned long y = 0x1;

//asma(x1, x2, y, a);
//print(a);

//x1 = 0xffffffffffffffff;
//x2 = x1;
y = 0x3;

unsigned long x[3];
x[0] = 5578483259559274746;
x[1] = 4496355565575787261;
x[2]= 0x5555555555555555;
printH(b);
b[0] = 123123123123123;
b[1] = 123123123123123;
unsigned long yx = 15756758847093065744; 
asmb(x, 2, yx, b);
//printH(b);
printf("a[0] = %lu\na[1] = %lu\n",b[0], b[1]);
return 0;
}
