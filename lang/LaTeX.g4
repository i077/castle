grammar LaTeX;

options {
    language=Python3;
}

WS
    : [ \r\n\t]+ -> channel (HIDDEN)
    ;

// Literal tokens

BS      : '\\';

BACKTICK: '`';

LPAREN  : '(';
RPAREN  : ')';
LCURLY  : '{';
RCURLY  : '}';
LBRACK  : '[';
RBRACK  : ']';

PLUS        : '+';
MINUS       : '-';
MULT        : '*';
DIV         : '/';
CARET       : '^';
AMPERSAND   : '&';

POINT   : '.';

EQ      : '=';
LT      : '<';
LTE     : '\\leq';
GT      : '>';
GTE     : '\\geq';
ASSIGN  : ':=';

CASES   : 'cases';
MATRIX  : 'matrix';
P_MATRIX: 'pmatrix';
B_MATRIX: 'bmatrix';
V_MATRIX: 'vmatrix';

UNDERSCORE : '_';
COMMA      : ',';

LETTER  : [a-zA-Z];
DIGIT   : [0-9];

CMD_CDOT        : '\\cdot';
CMD_TIMES       : '\\times';
CMD_DIV         : '\\div';
CMD_FRAC        : '\\frac';
CMD_BEGIN       : '\\begin';
CMD_END         : '\\end';
CMD_TO          : '\\to';
CMD_RIGHTARROW  : '\\rightarrow';
CMD_DD          : '\\dd';

FUNC_LIM        : '\\lim';
FUNC_INT        : '\\int';
FUNC_SUM        : '\\sum';

FUNC_LOG        : '\\log';
FUNC_LN         : '\\ln';
FUNC_EXP        : '\\exp';
FUNC_SIN        : '\\sin';
FUNC_COS        : '\\cos';
FUNC_TAN        : '\\tan';
FUNC_SEC        : '\\sec';
FUNC_CSC        : '\\csc';
FUNC_COT        : '\\cot';

CMD_LFLOOR      : '\\lfloor';
CMD_RFLOOR      : '\\rfloor';
CMD_LCEIL       : '\\lceil';

// Compound literals

number  : MINUS? DIGIT+ (POINT DIGIT*)?;

multichar_var : (LETTER | DIGIT)+;

// Variable names
var_name
    : LETTER                               #var_name_letter
    | BACKTICK name=multichar_var BACKTICK #var_name_multichar
    ;

var
    : var_name (UNDERSCORE tex_symb)?;

tex_symb
    : (LETTER | DIGIT)   #tex_symb_single
    | LCURLY expr RCURLY #tex_symb_multi
    ;

// Function names can either be builtin LaTeX commands or var names
func_name
    : func_builtin #func_name_builtin
    | var          #func_name_var
    ;

func_builtin
    : FUNC_SIN #sin | FUNC_COS #cos | FUNC_TAN #tan
    | FUNC_SEC #sec | FUNC_CSC #csc | FUNC_COT #cot
    | FUNC_EXP #exp | FUNC_LN #ln | FUNC_LOG #log
    ;

func_call
    // Function calls with normal syntax
    : func_name LPAREN (expr ((COMMA expr)+)*) RPAREN                                                          #func_call_var
    // Limits
    | FUNC_LIM UNDERSCORE LCURLY limitvar=var (CMD_TO | CMD_RIGHTARROW) limitto=expr RCURLY LCURLY expr RCURLY #func_lim
    // Integrals
    | FUNC_INT (UNDERSCORE tex_symb CARET tex_symb)? LCURLY expr CMD_DD var RCURLY                             #func_int
    // Floor/ceilings
    ;

// Rules
input
    :start EOF
    ;

start
    : relation   #start_relation
    | assignment #start_assignment
    ;

relation
    : expr relop=(EQ | LT | LTE | GT | GTE) expr
    ;

expr: add_expr;

add_expr
    : add_expr op=(PLUS | MINUS) add_expr #add_expr_recurse
    | mult_expr                           #add_expr_mult
    ;

mult_expr
    : mult_expr op=(MULT | CMD_TIMES | CMD_CDOT | DIV | CMD_DIV) mult_expr #mult_expr_recurse
    | pow_expr                                                             #mult_expr_pow
    ;

pow_expr
    : pow_expr CARET tex_symb #pow_expr_recurse
    | unit                    #pow_expr_unit
    ;

unit
    : sign=(PLUS | MINUS) unit  #unit_recurse      // Signed unit expressions
    | MINUS? LPAREN expr RPAREN #unit_paren        // Parentheticals, optionally signed
    | func_call                 #unit_func         // Function calls
    | var                       #unit_var          // Variable identifiers
    | number                    #unit_number       // Number literals
    | fraction                  #unit_fraction     // Fraction expressions
    | matrix_env                #unit_matrix       // Matrices
    | cases_env                 #unit_cases
    ;

arg_list
    : LPAREN var? RPAREN             #arg_list_single
    | LPAREN (var COMMA)* var RPAREN #arg_list_multi
    ;

func_def
    : arg_list (CMD_TO | CMD_RIGHTARROW) expr
    ;

assignment
    : var ASSIGN expr     #var_assign
    | var ASSIGN func_def #func_assign
    ;

fraction
    : CMD_FRAC LCURLY expr RCURLY LCURLY expr RCURLY
    ;

cases_env
    : CMD_BEGIN LCURLY CASES RCURLY
      (expr AMPERSAND relation BS BS)* expr AMPERSAND relation
      CMD_END LCURLY CASES RCURLY
    ;

matrix_last_row
    : (expr AMPERSAND)* expr (BS BS)?
    ;

matrix_row
    : (expr AMPERSAND)* expr BS BS
    ;

matrix_exp
    : matrix_row* matrix_last_row
    ;

matrix_env
    : CMD_BEGIN LCURLY open_mat_type=(MATRIX | V_MATRIX | B_MATRIX | P_MATRIX) RCURLY
      matrix_exp
      CMD_END LCURLY close_mat_type=(MATRIX | V_MATRIX | B_MATRIX | P_MATRIX) RCURLY
    ;

