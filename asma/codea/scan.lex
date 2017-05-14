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
#include "tree.h"
#include "y.tab.h"
%}

%%
"(*" BEGIN(comment);
<comment>[^*]* //\n 
<comment>"*"+[^*)]* //\n
<comment>"*"+")" /*printf("COMMENT %s\n", yytext);*/BEGIN(INITIAL);

"!=" return UNE;
\;	return SEMICOLON;
\(	return BOPEN;
\)  return BCLOSE;
\,	return COMMA;
\:	return COLON;
"="  return EQU;
\>  return GREATER;
\[  return SQOPEN;
\]	return SQCLOSE;
\-  return MINUS;
\+	return PLUS;
\*	return MUL;


"end" return END;
"return" return RETURN;
"goto" return GOTO;
"if" return IF;
"var" return VAR;
"and" return AND;
"not" return NOT;


{ID}	 	{return ID;}
{NUMBER} 	{	int i=0;
				int j=0;
				for(i,j;j<=yyleng;i++, j++){
					yytext[i] = yytext[j];
					if(yytext[j+1] == '_') {
						j++;
					}
				}
				yylval.number = atoi(yytext);
				return NUMBER;
				//printf("num %d\n", atoi(yytext));
			}
[ _\n\r\t]
.|\n exit(1);
%%

/*main() {
 
 yylex();

}*/
