#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int main(){
uint8_t a[24];

for(int i=0;i<24;i++)
{
	a[i] =0;
}
long long out=0;

asma(16,2,4,a);

for(int i =23; i>=0; i--){
	printf("%x", a[i]);
}
printf("\n");

return 0;
}
