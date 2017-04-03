%{#define YYSTYPE int
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
void yyerror(const char *str){
	fprintf(stderr, "error: %s\n", str);
	exit(2);
}

int yywrap(){
	return 1;
}

main(){
	yyparse();
}
%}

%token NUMBER ID SEMICOLON BOPEN BCLOSE COMMA COLON EQU GREATER SQOPEN SQCLOSE MINUS PLUS MUL UNE END RETURN GOTO IF VAR AND NOT

%%

Program: Funcdef SEMICOLON Program
	| 
	;

Funcdef: ID BOPEN Pars BCLOSE Stats END
	;

Pars: mayPars 
	;

mayPars:
	| ID COMMA Pars
	| ID
	;

Labeldef: ID COLON
	;

Labeldefs: 
	| Labeldefs Labeldef
	;

Stats:
	| Stats Labeldefs Stat SEMICOLON
	| Labeldefs Stat SEMICOLON
	;

Stat: RETURN Expr
	| GOTO ID
	| IF Cond GOTO ID
	| Lexpr EQU Expr
	| VAR ID EQU Expr
	| Term
	;

andCond: 
	| AND Cterm andCond
	;

Cond: Cterm andCond
	| NOT Cterm
	;
	
Cterm: BOPEN Cond BCLOSE
	| Expr UNE Expr
	| Expr GREATER Expr

	;

Lexpr: ID
	| Term SQOPEN Expr SQCLOSE
	;



Expr: Term pTerm
	| Term mTerm
	| minus Term
	;

mayExpr:
	| Expr
	;

pTerm:
	| pTerm PLUS Term
	;

mTerm:
	| mTerm MUL  Term
	;


minus:
	| minus MINUS
	;


beistrichExpr:
	| beistrichExpr Expr COMMA
	;

Term: BOPEN Expr BCLOSE 
	| ID
	| NUMBER
	| Term SQOPEN Expr SQCLOSE
	| ID BOPEN beistrichExpr mayExpr BCLOSE
	;
%%




















