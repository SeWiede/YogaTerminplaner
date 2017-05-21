%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "tree.h"
#include "util.h"

void yyerror(const char *str){
	fprintf(stderr, "error: %s\n", str);
	exit(2);
}

int yywrap(){
	return 1;
}

int labelID=2;

int registers[15] = {0};

main(){
	yyparse();
}


int gen_label() {
	return labelID++;
}

int oberfalselabel = 0;
int obertruelabel = 1;

Tree notLabels(Tree start) {
	if(OP_LABEL(start) == TYPE_AND) {
    	RIGHT_CHILD(start) = notLabels(RIGHT_CHILD(start));	
	}
	else {
		start->notLabels = !(start->notLabels);
	}
	return start;
}


Tree populateDecisionTree(Tree curr, int tl, int fl, int nl) {
	if(OP_LABEL(curr) == TYPE_AND) {
		LEFT_CHILD(curr) = populateDecisionTree(LEFT_CHILD(curr), gen_label(), fl, 0);
		RIGHT_CHILD(curr) = populateDecisionTree(RIGHT_CHILD(curr), tl, fl, 0);
	} else if(OP_LABEL(curr) == TYPE_NOT) {
		curr = populateDecisionTree(LEFT_CHILD(curr), fl, tl, 0);
	} else if(OP_LABEL(curr) == TYPE_COND) {
		curr = populateDecisionTree(LEFT_CHILD(curr), tl, fl, 0);
	} else {
		curr->truelabel = tl;
		curr->falselabel = fl;
		curr->nextlabel = 0;
	}
	return curr;
}
Tree gen_node_cond(Nodetype type, Tree left, Tree right, int const_num, char *name, int tl, int fl, int nl) {
	Tree t = malloc(sizeof(struct tree));
	OP_LABEL(t) = type;
	LEFT_CHILD(t) = left;
	RIGHT_CHILD(t) = right;
	t->truelabel = tl;
	t->falselabel = fl;
	t->nextlabel = nl;
	t->const_num = const_num;
	t->notLabels = 0;
	if(name != NULL) {
		t->name = strdup(name);
	}
	
	return t;
}

Tree gen_node(Nodetype type, Tree left, Tree right, int const_num, char *name) {
	Tree t = malloc(sizeof(struct tree));
	OP_LABEL(t) = type;
	LEFT_CHILD(t) = left;
	RIGHT_CHILD(t) = right;
	t->const_num = const_num;
	if(name != NULL) {
		t->name = strdup(name);
	}
	
	return t;
}


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
			//printf("Name here: %s, OCC here: %d\n", tmp->name, tmp->occ);
			if((tmp->occ == DEF) && (anyNameExists(tmp->next, tmp->name) == 1)){
			//	printf("defined or used previously\n");
				return 0;
			}
			if((tmp->occ == USE) && (nameExists(tmp->next, tmp->name, DEF, VARIABLE) == 0)) {
			//	printf("not defined yet\n");
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

@attributes {struct list * names;} Program Pars  mayPars  mayExpr beistrichExpr  
@attributes {char *name;} ID
@attributes {struct list *names; Tree node;} Lexpr Expr mayplus plusExpr maymul mulExpr minusExpr Term Stat Stats Labeldefs Labeldef Cond Cterm andCond
@attributes {int value;} NUMBER
@attributes {int neg; struct list *names; Tree node;} mayminus
@attributes {struct list *names; Tree node; char *functionname; struct list *parnames;} Funcdef
@traversal @lefttoright @postorder post
@traversal @preorder pre
%%

Program: Funcdef SEMICOLON Program
	@{
		@e Program.names : Funcdef.names;
		@Program.names@ = @Funcdef.names@;
		//@post printList(@Program.names@); 
		//@post printf("------------------------\n");
		@post if(checkNames(@Program.names@) == 0){ exit(3);}

		@post{
			populateParameters(@Funcdef.parnames@);
		}

		@post { 
			printf(".globl %s\n", @Funcdef.functionname@);
			printf(".type %s, %cfunction\n", @Funcdef.functionname@, 64);
			printf("%s:\n", @Funcdef.functionname@);
			//printf("\tpush %rbx\n \tpush %rbp\n \tpush %r12\n \tpush %r13\n \tpush %r14\n \tpush %r15\n");
		}


		
		@post {
			if(burm_label(@Funcdef.node@) == 0) {
				fprintf(stderr, "burm_label error\n");
			}
			else {
				burm_reduce(@Funcdef.node@, 1);
			}
		} 
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
		
		@i @Funcdef.node@ = @Stats.node@;

		@i @Funcdef.functionname@ = @ID.name@;
		@i @Funcdef.parnames@ = @Pars.names@;

		
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

Labeldefs: ID COLON
	@{
		@i @Labeldefs.names@ = createList(@ID.name@, DEF, LABEL, NULL);
		@i @Labeldefs.node@ = gen_node(TYPE_LABEL, NULL, NULL, 0, @ID.name@);
	@}
	| Labeldefs ID COLON	
	@{
		@i @Labeldefs.names@ = concatList(@Labeldefs.1.names@, createList(@ID.name@, DEF, LABEL, NULL));
		@i @Labeldefs.node@ = gen_node(TYPE_LABEL, @Labeldefs.1.node@, NULL, 0, @ID.name@);
	@}
	;

Stats: Labeldefs Stat SEMICOLON
	@{
		@i @Stats.names@ = @Stat.names@;
	
		@i @Stats.node@ = gen_node(TYPE_STATEMENTS, @Labeldefs.node@, @Stat.node@, 0, NULL);
	@}
	| Stat SEMICOLON
	@{
		@i @Stats.names@ = @Stat.names@;
	
		@i @Stats.node@ =  @Stat.node@;
	@}
	| Stats Labeldefs Stat SEMICOLON
	@{
		@e Stats.names : Stats.1.names Labeldefs.names Stat.names;
		@Stats.names@ = concatList(concatList(@Stat.names@, @Labeldefs.names@), @Stats.1.names@);

		@i @Stats.0.node@ = gen_node(TYPE_STATEMENTS, 
								gen_node(TYPE_STATEMENTS, @Stats.1.node@, @Labeldefs.node@, 0, NULL), 
													@Stat.node@, 0, NULL);
	@}
	| Stats Stat SEMICOLON
	@{
		@e Stats.names : Stats.1.names Stat.names;
		@Stats.names@ = concatList(@Stat.names@, @Stats.1.names@);

		@i @Stats.0.node@ = gen_node(TYPE_STATEMENTS, @Stats.1.node@, @Stat.node@, 0, NULL);
	@}
	;

Stat: RETURN Expr
	@{
		@e Stat.names : Expr.names;
		@Stat.names@ = @Expr.names@;
		
		@i @Stat.node@ = gen_node(TYPE_RETURN, @Expr.node@, NULL, 0, NULL);

	@}
	| GOTO ID
	@{
		@e Stat.names : ID.name;
		@Stat.names@ = createList(@ID.name@, USE, LABEL, NULL);

		@i @Stat.node@ = gen_node(TYPE_GOTO, NULL, NULL, 0, @ID.name@);
	@}
	| IF Cond GOTO ID
	@{
		@e Stat.names : Cond.names ID.name;
		@Stat.names@ = createList(@ID.name@, USE, LABEL, @Cond.names@);//concat+ create?


		@i @Stat.node@ = gen_node_cond(TYPE_IF, populateDecisionTree(@Cond.node@, obertruelabel, oberfalselabel, 0), NULL, 0, @ID.name@, obertruelabel, oberfalselabel, 0);
	@}
	| Lexpr EQU Expr
	@{
		@e Stat.names : Lexpr.names  Expr.names;
		@Stat.names@ = concatList(@Lexpr.names@, @Expr.names@);
	
		@i @Stat.node@ = gen_node(TYPE_ASSIGN, @Lexpr.node@, @Expr.node@, 0, NULL);
	@}
	| VAR ID EQU Expr
	@{
		@e Stat.names : ID.name Expr.names;
		@Stat.names@ = createList(@ID.name@, DEF, VARIABLE, @Expr.names@);

		@i @Stat.node@ = gen_node(TYPE_CREATE, @Expr.node@,  NULL, 0, @ID.name@);
	@}
	| Term
	@{
		@e Stat.names : Term.names;
		@Stat.names@ = @Term.names@; 
//prep for codec, Term stats wont generate assembler code in codeb
		@i @Stat.node@ = gen_node(TYPE_TERM, @Term.node@,  NULL, 0, NULL);
	@}
	;

andCond: Cterm
	@{
		@e andCond.names : Cterm.names;
		@andCond.names@ = @Cterm.names@;
	
		@i @andCond.node@ = @Cterm.node@;	
	@}
	| andCond AND Cterm
	@{
		@e andCond.names : andCond.1.names Cterm.names;
		@andCond.names@ = concatList(@Cterm.names@, @andCond.1.names@);
	
		@i @andCond.node@ = gen_node_cond(TYPE_AND, @andCond.1.node@, @Cterm.node@, 0, NULL, @Cterm.node@->truelabel, @Cterm.node@->falselabel, @Cterm.node@->nextlabel);	
	@}
	;

Cond: andCond 
	@{
		@e Cond.names : andCond.names;
		@Cond.names@ = @andCond.names@;

		@i @Cond.node@ = @andCond.node@;	
	@}
	| NOT Cterm
	@{
		@e Cond.names : Cterm.names;
		@Cond.names@  = @Cterm.names@;
		
		@i @Cond.node@ = gen_node(TYPE_NOT, @Cterm.node@, NULL, 0, NULL);
	@}
	;
	
Cterm: BOPEN Cond BCLOSE
	@{
		@e Cterm.names : Cond.names;
		@Cterm.names@ = @Cond.names@;

		@i @Cterm.node@	= gen_node(TYPE_COND, @Cond.node@, NULL, 0, NULL);
	@}
	| Expr UNE Expr
	@{
	    @e Cterm.names : Expr.0.names Expr.1.names;
		@Cterm.names@ = concatList(@Expr.0.names@, @Expr.1.names@);
		
		@i @Cterm.node@	= gen_node(TYPE_UNE, @Expr.0.node@, @Expr.1.node@, 0, NULL);
	@}
	| Expr GREATER Expr
	@{
		@e Cterm.names : Expr.0.names Expr.1.names;
		@Cterm.names@ = concatList(@Expr.0.names@, @Expr.1.names@);
	
		@i @Cterm.node@	= gen_node(TYPE_GREATER, @Expr.0.node@, @Expr.1.node@, 0, NULL);	
	@}

	;

Lexpr: ID
	@{
		@e Lexpr.names : ID.name;
		@Lexpr.names@ = createList(@ID.name@, USE, VARIABLE, NULL);

		@i @Lexpr.node@ = gen_node(TYPE_VAR_ASS, NULL, NULL, 0, @ID.name@);
	@}
	| Term SQOPEN Expr SQCLOSE
	@{
		@e Lexpr.names : Term.names Expr.names;
		@Lexpr.names@ = concatList(@Term.names@, @Expr.names@);

		
		@i @Lexpr.node@ = gen_node(TYPE_ARRAY, @Term.node@, @Expr.node@, 0, NULL);
	@}
	;



Expr: Term
	@{
		@e Expr.names : Term.names;
		@Expr.names@ = @Term.names@;

		@i @Expr.node@ = @Term.node@;
	@}
	| plusExpr
	@{
		@e Expr.names : plusExpr.names;
		@Expr.names@ = @plusExpr.names@;

		@i @Expr.node@ = @plusExpr.node@;
	@}
	| mulExpr
	@{
		@e Expr.names : mulExpr.names;
		@Expr.names@ = @mulExpr.names@;

		@i @Expr.node@ = @mulExpr.node@;
	@}
	| minusExpr
	@{
		@e Expr.names : minusExpr.names;
		@Expr.names@ = @minusExpr.names@;

		@i @Expr.node@ = @minusExpr.node@;
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

mayplus: Term
	@{
		@i @mayplus.names@ = @Term.names@;
		
		@i @mayplus.node@ = @Term.node@;
	@}
	| mayplus PLUS Term
	@{
		@e mayplus.names : Term.names mayplus.1.names;
		@mayplus.names@ = concatList(@Term.names@, @mayplus.1.names@); 

		@i @mayplus.0.node@ = gen_node(TYPE_ADD, @mayplus.1.node@,@Term.node@,  0, NULL);
	@}
	;

plusExpr: mayplus PLUS Term
	@{
		@e plusExpr.names : Term.names mayplus.names;
		@plusExpr.names@ = concatList(@Term.names@, @mayplus.names@);
		
		@i @plusExpr.node@ = gen_node(TYPE_ADD, @mayplus.node@,@Term.node@,  0, NULL);
	@}
	;

maymul: Term
	@{
		@i @maymul.names@ = @Term.names@;

		@i @maymul.node@ = @Term.node@;
	@}
	| maymul MUL Term
	@{
		@e maymul.0.names : Term.names maymul.1.names;
		@maymul.0.names@ = concatList(@Term.names@, @maymul.1.names@);

		@i @maymul.0.node@ = gen_node(TYPE_MUL, @maymul.1.node@, @Term.node@, 0, NULL);
	@}
	;

mulExpr: maymul MUL Term
	@{
		@e mulExpr.names : Term.names maymul.names;
		@mulExpr.names@ = concatList(@Term.names@, @maymul.names@);

		@i @mulExpr.node@ = gen_node(TYPE_MUL, @maymul.node@, @Term.node@, 0, NULL);
	@}
	;

mayminus: Term
	@{
		@e mayminus.names : Term.names;
		@mayminus.names@ = @Term.names@;

		@i @mayminus.node@ = @Term.node@;
		@i @mayminus.neg@ = 1;
	@} 
	| MINUS mayminus
	@{
		@e mayminus.0.names : mayminus.1.names;
		@mayminus.0.names@ = @mayminus.1.names@;

		@i @mayminus.0.node@ = @mayminus.1.node@;
		@i @mayminus.0.neg@ = !@mayminus.1.neg@;
	@}
	;

minusExpr: MINUS mayminus 
	@{
		@e minusExpr.names : mayminus.names;
		@minusExpr.names@ = @mayminus.names@;

		@e minusExpr.node: mayminus.node mayminus.neg;
		 {
			@minusExpr.node@ = @mayminus.node@;
			if(@mayminus.neg@ == 1) 
				@minusExpr.node@ = gen_node(TYPE_SUB, @mayminus.node@, NULL, 0, NULL);
		}
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

		@i @Term.node@ = @Expr.node@;
	@}
	| ID
	@{
		@e Term.names : ID.name;
		@Term.names@ = createList(@ID.name@, USE, VARIABLE, NULL);

		@i @Term.node@ = gen_node(TYPE_VAR, NULL, NULL, 0, @ID.name@);
	@}
	| NUMBER
	@{
		@i @Term.names@ = NULL;
		@i @Term.node@ = gen_node(TYPE_CONST, NULL, NULL, @NUMBER.value@, NULL);
	@}
	| Term SQOPEN Expr SQCLOSE
	@{
		@e Term.names : Term.1.names Expr.names;
		@Term.names@ = concatList(@Expr.names@ , @Term.1.names@);

		@i @Term.node@ = gen_node(TYPE_ARRAY, @Term.1.node@, @Expr.node@, 0, NULL);
	@}
	| ID BOPEN beistrichExpr mayExpr BCLOSE
	@{
		@e Term.names: beistrichExpr.names mayExpr.names;
		@Term.names@ = concatList(@beistrichExpr.names@, @mayExpr.names@);

		@i @Term.node@ = NULL;
	@}
	;
%%




















