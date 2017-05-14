#ifndef TREE_H
#define TREE_H

#define LEFT_CHILD(p) (p->child[0])
#define RIGHT_CHILD(p) (p->child[1])
#define OP_LABEL(p) (p->type)
#define PANIC printf
#define STATE_LABEL(p) (p->state)

enum type {TYPE_VAR=0, TYPE_CONST=1, TYPE_ADD=2, TYPE_SUB=3, TYPE_MUL=4, TYPE_ARRAY=5};
typedef enum type Type;

typedef struct tree {
	Type type;
	struct tree *child[2];
	
 	int reg;
	int const_num;
	char *name;
	
	struct burm_state *state;
} *NODEPTR_TYPE, *Tree;

Tree tree;
#endif
