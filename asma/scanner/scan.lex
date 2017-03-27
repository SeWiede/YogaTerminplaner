DIGIT [0-9]
LETTER [a-zA-Z]
ID {LETTER}({DIGIT}|{LETTER})*
NUMBER {DIGIT}+("_"{DIGIT}*)*
KEYWORD end|return|goto|if|var|and|not
SPECIAL [\;\(\)\,\:\=\>\[\]\-\+\*]
CO \(\*
CC \)\*

%x comment

%{
#include <math.h>
%}

%%
"(*" BEGIN(comment);
<comment>[^*]* //\n 
<comment>"*"+[^*)]* //\n
<comment>"*"+")" /*printf("COMMENT %s\n", yytext);*/BEGIN(INITIAL);

{KEYWORD}|{SPECIAL}|"!=" 	{printf("%s\n", yytext);;}
{ID}	 	{printf("id %s\n", yytext);exit(0);}
{NUMBER} 	{	int i=0;
				int j=0;
				for(i,j;j<=yyleng;i++, j++){
					yytext[i] = yytext[j];
					if(yytext[j+1] == '_') {
						j++;
					}
				}
				printf("num %d\n", atoi(yytext));
			}
[ _\n\r\t]
.|\n exit(1);
%%

main() {
 
 yylex();

}
