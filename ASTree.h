/**Terminal node**/
struct ast_NUMBER_node // for constant numbers
{
	int node_type;
	int value;
};

struct ast_PARAMETER_node 	//for function parameter node
{
	int node_type;
	int value;
	char* name;
};

struct ast_BOOL_node 	//for bool value "#f #t"
{
	int node_type;
	char* value;
};

/**Non-terminal node**/
struct ast_node 	 // for num expression"+ - * / mod > < "
{
	int node_type;
	int value;
	struct ast_node * left;
	struct ast_node * right;
};

struct ast_logic_node 	//for logic expression "and or not"
{
	int node_type;

	char* value;

	struct ast_logic_node * left;

	struct ast_logic_node * right;
};

struct ast_define_node //for define expression "define name function"
{
	int node_type;

	char* name;

	struct ast_node * function;
};

struct ast_if_node // for "if/else" statements
{
	int node_type;
	struct ast_node * condition;
	struct ast_node * if_branch;
	struct ast_node * else_branch;
};

struct ast_function_node // for function calls
{
	int node_type;
	struct ast_node * arguments;
	struct ast_node * function_body;
};






struct ast_node *new_ast_NUMBER_node (int value);

struct ast_node *new_ast_PARAMETER_node(char* name, int value);

struct ast_node *new_ast_BOOL_node (char* value);

struct ast_node *new_ast_node (int node_type, struct ast_node * left, struct ast_node * right);

struct ast_node *new_ast_function_node (struct ast_node * function_body, struct ast_node * arguments);

struct ast_node *new_ast_if_node (struct ast_node * condition, struct ast_node * if_branch, struct ast_node * else_branch);

struct ast_node *new_ast_logic_node (int node_type, char* value, struct ast_node * left, struct ast_node * right);

struct ast_node *new_ast_define_node (char* name, struct ast_node * function);

void free_ast_tree (struct ast_node * ast_tree);