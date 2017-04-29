%{#define YYSTYPE char *
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

NameList createList(char *name,  Occurence occ, Type typ, NameList next)
{
	NameList list = malloc(sizeof(Name));
	list->name = name;
	list->typ = typ;
	list->occ = occ;
	list->next = next;
	return list;
}

void printList(NameList list) 
{
	if(list == NULL) {
		return;
	}

	do {
		printf("%s - %s - %s\n", list->name, 
			list->occ == USE ? "USAGE" : "DEFINITION", 
			list->typ == LABEL ? "LABEL" : "VARIABLE");
		list = list->next;
	}
	while(list != NULL);
}

NameList concatList(NameList list1, NameList list2) 
{
	NameList *temp = &list1;
	while(*temp != NULL) {
		temp = &((*temp)->next);
	}
	*temp = list2;
	return list1;
}

int nameExists(NameList n, char *name, Occurence occ, Type typ){
	while(n != NULL){
		if((occ == OCC_ANY || n->occ == occ) 
			&& (typ == TYP_ANY || n->typ == typ) 
			&& strcmp(n->name, name) == 0){
				return 1;	
		}
		n = n->next;
	}	
	return 0;
}

int anyNameExists(NameList n, char * name){
	return nameExists(n, name, OCC_ANY, TYP_ANY);
}

int checkNames(NameList n){
	NameList tmp = n;
	NameList head = n;
	while(tmp != NULL){
		switch (tmp->typ){
		case VARIABLE:
			printf("Name here: %s, OCC here: %d\n", tmp->name, tmp->occ);
			if((tmp->occ == DEF) && (anyNameExists(tmp->next, tmp->name) == 1)){
				printf("defined or used previously\n");
				return 0;
			}
			if((tmp->occ == USE) && (nameExists(tmp->next, tmp->name, DEF, VARIABLE) == 0)) {
				printf("not defined yet\n");
				return 0;
			}
			break;
		case LABEL:
			if((tmp->occ == DEF) && (nameExists(tmp->next, tmp->name, DEF, TYP_ANY) == 1))
				return 0;
			if((tmp->occ == USE) && (nameExists(head, tmp->name, DEF, LABEL) == 0))
				return 0;
			break;
		default:
			return 0;
		}
		tmp = tmp->next;
	}
	return 1;
}

%}

%token NUMBER ID SEMICOLON BOPEN BCLOSE COMMA COLON EQU GREATER SQOPEN SQCLOSE MINUS PLUS MUL UNE END RETURN GOTO IF VAR AND NOT

@attributes {struct list * names;} Program Funcdef Pars  mayPars Stats Stat Labeldefs Labeldef Expr Cond Lexpr Term andCond Cterm mayExpr mayplus plusExpr maymul mulExpr minusExpr beistrichExpr 
@attributes {char *name;} ID
@traversal @lefttoright @postorder post

%%

Program: Funcdef SEMICOLON Program
	@{
		@e Program.names : Funcdef.names;
		@Program.names@ = @Funcdef.names@;
		@post printList(@Program.names@); 
		@post printf("------------------------\n");
		@post if(checkNames(@Program.names@) == 0) exit(3); 
	@}
	|
	@{
		@i @Program.names@ = NULL;
	@} 
	;

Funcdef: ID BOPEN Pars BCLOSE Stats END
	@{
		@e Funcdef.names : Pars.names Stats.names;
		@Funcdef.names@ = concatList(@Stats.names@, @Pars.names@);
	@}	
	;

Pars: 
	@{
		@i @Pars.names@ = NULL; 
	@}
	| mayPars 
	@{
		@e Pars.names : mayPars.names;
		@Pars.names@ = @mayPars.names@;
	@}
	;

mayPars: ID COMMA Pars
	@{
		@e mayPars.names : ID.name Pars.names;
		@mayPars.names@ = createList(@ID.name@, DEF, VARIABLE, @Pars.names@);
	@}
	| ID
	@{
	   @e mayPars.names : ID.name;
	   @mayPars.names@ = createList(@ID.name@, DEF, VARIABLE, NULL);
	@}
	;

Labeldef: ID COLON
	@{
		@e Labeldef.names : ID.name;
		@Labeldef.names@ = createList(@ID.name@, DEF, LABEL, NULL);
	@}
	;

Labeldefs: 
	@{
		@i @Labeldefs.names@ = NULL;
	@}
	| Labeldefs Labeldef	
	@{
		@e Labeldefs.names : Labeldefs.1.names Labeldef.names;
		@Labeldefs.names@ = concatList(@Labeldefs.1.names@, @Labeldef.names@);
	@}
	;

Stats:
	@{
		@i @Stats.names@ = NULL;
	@}
	| Stats Labeldefs Stat SEMICOLON
	@{
		@e Stats.names : Stats.1.names Labeldefs.names Stat.names;
		@Stats.names@ = concatList(concatList(@Stat.names@, @Labeldefs.names@), @Stats.1.names@);
	@}
	;

Stat: RETURN Expr
	@{
		@e Stat.names : Expr.names;
		@Stat.names@ = @Expr.names@;
	@}
	| GOTO ID
	@{
		@e Stat.names : ID.name;
		@Stat.names@ = createList(@ID.name@, USE, LABEL, NULL);
	@}
	| IF Cond GOTO ID
	@{
		@e Stat.names : Cond.names ID.name;
		@Stat.names@ = createList(@ID.name@, USE, LABEL, @Cond.names@);//concat+ create?
	@}
	| Lexpr EQU Expr
	@{
		@e Stat.names : Lexpr.names  Expr.names;
		@Stat.names@ = concatList(@Lexpr.names@, @Expr.names@);
	@}
	| VAR ID EQU Expr
	@{
		@e Stat.names : ID.name Expr.names;
		@Stat.names@ = createList(@ID.name@, DEF, VARIABLE, @Expr.names@);
	@}
	| Term
	@{
		@e Stat.names : Term.names;
		@Stat.names@ = @Term.names@; 
	@}
	;

andCond: 
	@{
		@i @andCond.names@ = NULL;
	@}
	| AND Cterm andCond
	@{
		@e andCond.names : Cterm.names andCond.1.names;
		@andCond.names@ = concatList(@Cterm.names@, @andCond.1.names@);
	@}
	;

Cond: Cterm andCond
	@{
		@e Cond.names : Cterm.names andCond.names;
		@Cond.names@ = concatList(@Cterm.names@, @andCond.names@);
	@}
	| NOT Cterm
	@{
		@e Cond.names : Cterm.names;
		@Cond.names@  = @Cterm.names@;
	@}
	;
	
Cterm: BOPEN Cond BCLOSE
	@{
		@e Cterm.names : Cond.names;
		@Cterm.names@ = @Cond.names@;
	@}
	| Expr UNE Expr
	@{
	    @e Cterm.names : Expr.names Expr.1.names;
		@Cterm.names@ = concatList(@Expr.names@, @Expr.1.names@);
	@}
	| Expr GREATER Expr
	@{
		@e Cterm.names : Expr.names Expr.1.names;
		@Cterm.names@ = concatList(@Expr.names@, @Expr.1.names@);
	@}

	;

Lexpr: ID
	@{
		@e Lexpr.names : ID.name;
		@Lexpr.names@ = createList(@ID.name@, USE, VARIABLE, NULL);
	@}
	| Term SQOPEN Expr SQCLOSE
	@{
		@e Lexpr.names : Term.names Expr.names;
		@Lexpr.names@ = concatList(@Term.names@, @Expr.names@);
	@}
	;



Expr: Term
	@{
		@e Expr.names : Term.names;
		@Expr.names@ = @Term.names@;
	@}
	| plusExpr
	@{
		@e Expr.names : plusExpr.names;
		@Expr.names@ = @plusExpr.names@;
	@}
	| mulExpr
	@{
		@e Expr.names : mulExpr.names;
		@Expr.names@ = @mulExpr.names@;
	@}
	| minusExpr
	@{
		@e Expr.names : minusExpr.names;
		@Expr.names@ = @minusExpr.names@;
	@}
	;

mayExpr:
	@{
		@i @mayExpr.names@ = NULL;
	@}
	| Expr
	@{
		@e mayExpr.names : Expr.names;
		@mayExpr.names@ = @Expr.names@;
	@}
	;

mayplus:
	@{
		@i @mayplus.names@ = NULL,
	@}
	| PLUS Term mayplus
	@{
		@e mayplus.names : Term.names mayplus.1.names;
		@mayplus.names@ = concatList(@Term.names@, @mayplus.1.names@); 
	@}
	;

plusExpr: Term PLUS Term mayplus
	@{
		@e plusExpr.names : Term.names Term.1.names mayplus.names;
		@plusExpr.names@ = concatList(concatList(@Term.names@, @Term.1.names@), @mayplus.names@);
	@}
	;

maymul:
	@{
		@i @maymul.names@ = NULL;
	@}
	| MUL Term maymul
	@{
		@e maymul.names : Term.names maymul.1.names;
		@maymul.names@ = concatList(@Term.names@, @maymul.1.names@);
	@}
	;

mulExpr: Term MUL Term maymul
	@{
		@e mulExpr.names : Term.names Term.1.names maymul.names;
		@mulExpr.names@ = concatList(concatList(@Term.names@, @Term.1.names@), @maymul.names@);
	@}
	;

mayminus: 
	| mayminus MINUS
	;

minusExpr: mayminus MINUS Term
	@{
		@e minusExpr.names : Term.names;
		@minusExpr.names@ = @Term.names@;
	@}
	;


beistrichExpr:
	@{
		@i @beistrichExpr.names@ = NULL;
	@}
	| beistrichExpr Expr COMMA
	@{
		@e beistrichExpr.names : beistrichExpr.1.names Expr.names;
		@beistrichExpr.names@ = concatList(@beistrichExpr.1.names@, @Expr.names@);
	@}
	;

Term: BOPEN Expr BCLOSE 
	@{
		@e Term.names : Expr.names;
		@Term.names@ = @Expr.names@;
	@}
	| ID
	@{
		@e Term.names : ID.name;
		@Term.names@ = createList(@ID.name@, USE, VARIABLE, NULL);
	@}
	| NUMBER
	@{
		@i @Term.names@ = NULL;
	@}
	| Term SQOPEN Expr SQCLOSE
	@{
		@e Term.names : Term.1.names Expr.names;
		@Term.names@ = concatList(@Expr.names@ , @Term.1.names@);
	@}
	| ID BOPEN beistrichExpr mayExpr BCLOSE
	@{
		@e Term.names: beistrichExpr.names mayExpr.names;
		@Term.names@ = concatList(@beistrichExpr.names@, @mayExpr.names@);
	@}
	;
%%




















