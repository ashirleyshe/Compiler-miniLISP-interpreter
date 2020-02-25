%{
	#include<iostream>
    #include<cstdlib>
    #include "AST.h"
    #include<string>
	#include<string.h>
	#include <stdio.h>
    #include<stack>
    #include<vector> 
    extern int yylex(void);
    void yyerror(const char *msg);
    std::stack<ASTType> stack_type;
    ASTNode *root;
    int Calc(ASTNode *);
    bool ASTLogical(ASTNode *);
    ASTVal* Visit(ASTNode *);
    bool ASTEqual(ASTNode *node);
    ASTNode* Child2(ASTNode *exp_1, ASTNode *exp2);
    ASTNode* Child3(ASTNode *exp_1, ASTNode *exp_2, ASTNode *exp_3);
%}

%union {
    bool b;
    int num;
    ASTNode *node;
}
%token<b> BOOL
%token<num> NUM
%token MOD AND OR NOT PRINT_NUM PRINT_BOOL
%type<node> program stmt stmts print_stmt exps exp
%type<node> plus minus multiply divid modulus greater smaller equal
%type<node> num_op logical_op
%type<node> and_op or_op not_op

%left BOOL NUM ID
%left '+' '-'
%left '*' '/' MOD
%left AND OR NOT
%left '(' ')'
%nonassoc UMINUS
%%
program: stmt stmts    { stack_type.push(AST_ROOT); $$ = Child2($1, $2); root = $$; }
        ;
stmts:  stmt stmts     { stack_type.push(AST_ROOT); $$ = Child2($1, $2); }
        | /* lambda */ { stack_type.push(AST_NULL); $$ = Child2(NULL, NULL); }
        ;
stmt:   exp 
        | print_stmt 
        ;
print_stmt: '(' PRINT_NUM exp ')'  { $$ = Child2($3, NULL); }
          | '(' PRINT_BOOL exp ')' { $$ = Child2($3, NULL); }
          ;
exps:   exp exps {
            $$ = (ASTNode *)malloc(sizeof(ASTNode));
            $$->type = stack_type.top();
            $$->lhs = $1;
            $$->rhs = $2;
        }
        | /* lambda */ { stack_type.push(AST_NULL); $$ = Child2(NULL, NULL); }
        ;
exp:    BOOL {
            ASTBool *b = (ASTBool *)malloc(sizeof(ASTBool));
            b->type = AST_BOOL;
            b->b = $1;
            $$ = (ASTNode *)b;
        }
        | NUM  {
            ASTNum *num = (ASTNum *)malloc(sizeof(ASTNum));
            num->type = AST_NUM;
            num->num = $1;
            $$ = (ASTNode *)num;
        }
        | num_op 
        | logical_op
        ;
		
num_op:   plus 
        | minus 
        | multiply 
        | divid 
        | modulus 
        | greater 
        | smaller 
        | equal 
        ;
        plus:  '(' '+' exp exp exps ')'     { $$ = Child3($3, $4, $5); }
            ;
        minus: '(' '-' exp exp ')'          { $$ = Child2($3, $4); }
            ;
        multiply: '(' '*' exp exp exps ')'  { $$ = Child3($3, $4, $5); }
            ;
        divid: '(' '/' exp exp ')'          { $$ = Child2($3, $4); }
            ;
        modulus: '(' MOD exp exp ')'        { $$ = Child2($3, $4); }
            ;
        greater: '(' '>' exp exp ')'        { $$ = Child2($3, $4); }
            ;
        smaller: '(' '<' exp exp ')'        { $$ = Child2($3, $4); }
            ;
        equal: '(' '=' exp exp exps ')'     { $$ = Child3($3, $4, $5); }
            ;
				
logical_op:   and_op 
            | or_op 
            | not_op 
            ;
        and_op: '(' AND exp exp exps ')' { $$ = Child3($3, $4, $5); }
                ;
        or_op: '(' OR exp exp exps ')'   { $$ = Child3($3, $4, $5); }
                ;
        not_op: '(' NOT exp ')'         { $$ = Child2($3, NULL); }
                ;
%%
void yyerror(const char *msg) {
    fprintf(stderr, "%s\n", msg);
    exit(0);
}

ASTNode* Child2(ASTNode *exp_1, ASTNode *exp_2) {
    ASTNode *reduce = (ASTNode *)malloc(sizeof(ASTNode));
    reduce->type = stack_type.top();
    reduce->lhs = exp_1;
    reduce->rhs = exp_2;
    stack_type.pop();
    return reduce;
}

ASTNode* Child3(ASTNode *exp_1, ASTNode *exp_2, ASTNode *exp_3) {
    ASTNode *reduce = (ASTNode *)malloc(sizeof(ASTNode));
    reduce->type = stack_type.top();
    reduce->lhs = exp_1;
    ASTNode *rhs = (ASTNode *)malloc(sizeof(ASTNode));
    rhs->type = stack_type.top();
    rhs->lhs = exp_2;
    rhs->rhs = exp_3;
    reduce->rhs = rhs;
    stack_type.pop();
    return reduce;
}

int Calc(ASTNode *node) {
    int val;
    ASTNum *num = (ASTNum *)node;
    switch(node->type) {
        case AST_ADD:
            val = Calc(node->lhs) + Calc(node->rhs);
            if (node->rhs->type == AST_NULL) val--;
            break;
        case AST_MINUS:
            val = Calc(node->lhs) - Calc(node->rhs);
            break;
        case AST_MUL:
            val = Calc(node->lhs) * Calc(node->rhs);
            break;
        case AST_DIV:
            val = Calc(node->lhs) / Calc(node->rhs);
            break;
        case AST_MOD:
            val = Calc(node->lhs) % Calc(node->rhs);
            break;
        case AST_NUM:
            val = num->num;
            break;
        case AST_GREATER:
            if (Calc(node->lhs) > Calc(node->rhs)) val = 1;
            else val = 0;
            break;
        case AST_SMALLER:
            if (Calc(node->lhs) < Calc(node->rhs)) val = 1;
            else val = 0;
            break;
        case AST_NULL:
            val = 1;
            break;
        default:
            puts("syntax error");
            exit(0);
            break;
    }
    return val;
}

bool ASTEqual(ASTNode *node) {
    if (node->rhs->type != AST_NULL) {
            /* represent true and false */
        if (Calc(node->lhs) == Calc(node->rhs->lhs)) 
            return ASTEqual(node->rhs);
        else 
            return false;
    } 
    else {
        return true;
    }
}

bool ASTLogical(ASTNode *node) {
    bool b;
    ASTBool *b_s = (ASTBool *)node;
    switch(node->type) {
        case AST_AND:
            b = ASTLogical(node->lhs) && ASTLogical(node->rhs);
            break;
        case AST_OR:
            if (node->rhs->type == AST_NULL) {
                b = ASTLogical(node->lhs);
            } 
            else {
                b = ASTLogical(node->lhs) || ASTLogical(node->rhs);
            }
            break;
        case AST_NOT:   
            b = !ASTLogical(node->lhs);
            break;
        case AST_GREATER:
        case AST_SMALLER:
            if (Calc(node) == 1) b = true;
            else b = false;
            break;
        case AST_EQUAL:
            b = ASTEqual(node);
            break;
        case AST_BOOL:            
            b = b_s->b;
            break;
        case AST_NULL:
            b = true;
            break;
        default:
            puts("syntax error");
            exit(0);
            break;
    }
    return b;
}

ASTVal* Visit(ASTNode *node) {
    ASTVal *v = (ASTVal *)malloc(sizeof(ASTVal));
    switch(node->type) {
        case AST_ROOT:
            Visit(node->lhs);
            Visit(node->rhs);
            break;
        case AST_ADD:
        case AST_MINUS:
        case AST_MUL:
        case AST_DIV:
        case AST_MOD:
        case AST_NUM:
            v->type = AST_NUM;
            v->num = Calc(node);
            break;
        case AST_AND:
        case AST_OR:
        case AST_NOT:        
        case AST_GREATER:
        case AST_SMALLER:
        case AST_EQUAL:
        case AST_BOOL:
            v->type = AST_BOOL;
            v->b = ASTLogical(node);
            break;
        case AST_PNUM:
            v = Visit(node->lhs);
            printf("%d\n", v->num);
            break;
        case AST_PBOOL:
            v = Visit(node->lhs);
            printf(v->b ? "#t\n" : "#f\n");
            break;
        case AST_NULL:
            /* do nothing */
            break;
        default:
            puts("syntax error");
            exit(0);
            break;
    }
    return v;
}


int main(int argc, char *argv[]) {
    yyparse();
    Visit(root);
    return(0);
}
