#include "ASTree.h"

struct ast_node *
new_ast_NUMBER_node (int value)
{
	struct ast_NUMBER_node * ast_node =
		malloc (sizeof (struct ast_NUMBER_node));

	ast_node->node_type = 'N';

	ast_node->value = value;

	return (struct ast_node *) ast_node;
}

struct ast_node *
new_ast_PARAMETER_node(char* name, int value)
{
	struct ast_PARAMETER_node * ast_node =
		malloc (sizeof(struct ast_PARAMETER_node));

	ast_node->node_type = 'P';
	ast_node->name = name;
	ast_node->value = value;

	return (struct ast_node *) ast_node;
}

struct ast_node *
new_ast_BOOL_node (char* value)
{
	struct ast_BOOL_node * ast_node = 
		malloc(sizeof (struct ast_BOOL_node));

	ast_node->node_type = 'B';
	ast_node->value = value;

	return ast_node;
};






struct ast_node *new_ast_node (int node_type,struct ast_node * left,struct ast_node * right)
{
	struct ast_node * ast_node = malloc (sizeof (struct ast_node));

	ast_node->node_type = node_type;

	ast_node->left = left;
	ast_node->right = right;

	return ast_node;
}

struct ast_node *
new_ast_function_node (struct ast_node * arguments,
					  struct ast_node * function_body)
{
	struct ast_function_node * ast_node =
		malloc (sizeof (struct ast_function_node));

	ast_node->node_type = 'F';

	ast_node->arguments = arguments;
	ast_node->function_body = function_body;

	return (struct ast_node *) ast_node;
}

struct ast_node *
new_ast_if_node (struct ast_node * condition,
                 struct ast_node * if_branch,
                 struct ast_node * else_branch)
{
	struct ast_if_node * ast_node =
		malloc (sizeof (struct ast_if_node));

	ast_node->node_type = 'I';

	ast_node->condition = condition;
	ast_node->if_branch = if_branch;
	ast_node->else_branch = else_branch;
  
	return (struct ast_node *) ast_node;
}

struct ast_node *
new_ast_logic_node (int node_type, char* value,
					struct ast_node * left,
					struct ast_node * right)
{
	struct ast_logic_node * ast_node = 
		malloc(sizeof (struct ast_logic_node));

	ast_node->node_type = node_type;
	ast_node->value = value;
	ast_node->left = left;
	ast_node->right = right;

	return (struct ast_node *) ast_node;
}

struct ast_node *
new_ast_define_node (char* name,
					 struct ast_node * function)
{
	struct ast_define_node * ast_node = 
		malloc(sizeof (struct ast_define_node));

	ast_node->node_type = 'D';
	ast_node->name = name;
	ast_node->function = function;	
};

void free_ast_tree (struct ast_node * ast_tree)
{
  if (!ast_tree) return;

  switch (ast_tree->node_type)
  {
    /* two sub trees */
    case '+':
    case '-':
    case '*':
    case '/':
    case 'L':
      free_ast_tree (ast_tree->right);

    /* one sub tree */
    case 'M':
      free_ast_tree (ast_tree->left);

    /* no sub trees */
    case 'S':
    case 'N':
      break;

    case 'A':

      break;

    case 'I':

      break;
    case 'F':
      {
        struct ast_function_node * node =
          (struct ast_function_node *) ast_tree;

        if (node->arguments)
        {
          free_ast_tree (node->arguments);
        }
      }
      break;

    default:
      printf ("Error: Bad node type '%c' to free!\n", ast_tree->node_type);
  }

  free (ast_tree);
}