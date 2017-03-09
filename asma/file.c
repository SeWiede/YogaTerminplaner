#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

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


int main(){
uint8_t a[24];
uint8_t b[24];

for(int i=0;i<24;i++)
{
	a[i] =0;
	b[i] =0;
}
long long out=0;

unsigned long x1 = 0xffffffffffffffff;
unsigned long x2 = x1;
unsigned long y = 0x1;

asma(x1, x2, y, a);
print(a);

x1 = 0xffffffffffffffff;
x2 = x1;
y = 0x1;
print(b);
asmb(&x1, 1, y, b);
print(b);

return 0;
}
