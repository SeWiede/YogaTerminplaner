%{
#include "tree.h"
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




Tree gen_node(Type type, Tree left, Tree right, int const_num, char *name){
	Tree t = malloc(sizeof(struct tree));
	OP_LABEL(t) = type;
	LEFT_CHILD(t) = left;
	RIGHT_CHILD(t) = right;
	t->const_num = const_num;
	t->name = strdup(name);
	return t;	
}

%}
%union{
	char *name;
	int number;
	Tree node;
}
%token <number> NUMBER
%token <name> ID
%type <node> Expr mayplus plusExpr maymul mulExpr mayminus minusExpr Term
%start Stats 
%left PLUS MUL MINUS
%token SEMICOLON BOPEN BCLOSE COMMA COLON EQU GREATER SQOPEN SQCLOSE MINUS PLUS MUL UNE END RETURN GOTO IF VAR AND NOT

%%

Program: Funcdef SEMICOLON Program
	| 
	;

Funcdef: ID BOPEN Pars BCLOSE Stats END
	;

Pars: 
	| mayPars 
	;

mayPars: ID COMMA Pars
	| ID
	;

Stats: RETURN Expr SEMICOLON {if(burm_label($2) ==0)
							fprintf(stderr, "wrong\n");
						else
							burm_reduce($2, 1);};


Expr: Term {$$= $1;}
	| plusExpr {$$= $1;}
	| mulExpr {$$= $1;}
	| minusExpr {$$= $1;}
	;


mayplus: Term {$$ = $1;}
	| Term PLUS mayplus {$$ = gen_node(TYPE_ADD,$1, $3, 0, NULL);}
	;

plusExpr: Term PLUS mayplus {$$ = gen_node(TYPE_ADD,$1,$3, 0, NULL);}
	;

maymul: Term {$$ = $1;}
	| Term MUL maymul {$$ = gen_node(TYPE_MUL, $1, $3, 0, NULL);}
	;

mulExpr: Term MUL maymul {$$ =  gen_node(TYPE_MUL, $1, $3, 0, NULL);}
	;

mayminus: {$$ = NULL;}
	| mayminus MINUS {$$ = gen_node(TYPE_SUB, $1, NULL, 0, NULL);}
	;

minusExpr: mayminus MINUS Term {$$ = gen_node(TYPE_SUB, $1, $3, 0, NULL);}
	;


Term: BOPEN Expr BCLOSE {$$= $2;}
	| ID {$$ = gen_node(TYPE_VAR, NULL, NULL, 0, $1);}
	| NUMBER {$$= gen_node(TYPE_CONST, NULL, NULL, $1, NULL);}
	| Term SQOPEN Expr SQCLOSE
	;
%%




main(){
	yyparse();
}
















