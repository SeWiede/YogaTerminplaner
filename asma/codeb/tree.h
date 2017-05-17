#ifndef TREE_H
#define TREE_H
#include <stdlib.h>
#define LEFT_CHILD(p) (p->child[0])
#define RIGHT_CHILD(p) (p->child[1])
#define OP_LABEL(p) (p->type)
#define PANIC printf
#define STATE_LABEL(p) (p->state)


enum node_type {TYPE_VAR=0, TYPE_CONST=1, TYPE_ADD=2, TYPE_SUB=3, TYPE_MUL=4, TYPE_ARRAY=5, TYPE_STATEMENTS=6, TYPE_CREATE=7, TYPE_RETURN=8, TYPE_ASSIGN=9, TYPE_VAR_ASS};
typedef enum node_type Nodetype;

typedef struct tree {
	Nodetype type;
	struct tree *child[2];
	
 	int reg;
	int const_num;
	char *name;

	char *array_string;	
	struct burm_state *state;
} *NODEPTR_TYPE, *Tree;

Tree tree;
#endif
