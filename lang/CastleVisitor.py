import sys
from antlr4 import FileStream, InputStream, Lexer, Parser, CommonTokenStream
from LaTeXVisitor import LaTeXVisitor
from LaTeXParser import LaTeXParser as parse
from LaTeXLexer import LaTeXLexer
from structures import *

class CastleVisitor(LaTeXVisitor):
    def CastleVisitor(self, state: dict):
        self.state = state

    def visitEntry(self, ctx:parse.EntryContext):
        """entry
        castle_input EOF """
        return self.visit(ctx.castle_input())

    #Basic arithmetic and expr ===================================================
    def visitAdd_expr_recurse(self, ctx:parse.Add_expr_recurseContext):
        """add_expr_recurse 
        add_expr op=(PLUS | MINUS) add_expr"""
        if ctx.op.type == parse.PLUS:
            return self.visit(ctx.add_expr(0)) + self.visit(ctx.add_expr(1))
        else:
            return self.visit(ctx.add_expr(0)) - self.visit(ctx.add_expr(1))

    def visitMult_expr_recurse(self, ctx:parse.Mult_expr_recurseContext):
        """mult_expr_recurse
        mult_expr op=(MULT | CMD_TIMES | CMD_CDOT | DIV | CMD_DIV) mult_expr """
        if ctx.op.type in {parse.DIV, parse.CMD_DIV}:
            return self.visit(ctx.mult_expr(0)) // self.visit(ctx.mult_expr(1))
        else:
            return self.visit(ctx.mult_expr(0)) * self.visit(ctx.mult_expr(1))

    def visitPow_expr_recurse(self, ctx:parse.Pow_expr_recurseContext):
        """pow_expr_recurse
        pow_expr CARET tex_symb """
        return self.visit(ctx.pow_expr) ** self.visit(ctx.tex_symb)

    def visitUnit_recurse(self, ctx:parse.Unit_recurseContext):
        """unit_recurse
        sign=(PLUS | MINUS) unit """
        if ctx.sign.type == parse.MINUS:
            return -1*self.visit(ctx.unit)
        else:
            return self.visit(ctx.unit)

    def visitUnit_paren(self, ctx:parse.Unit_parenContext):
        """unit_paren
        MINUS? LPAREN expr RPAREN """
        return (-1 if ctx.MINUS() else 1) * self.visit(ctx.expr)

    def visitNumber(self, ctx:parse.NumberContext):
        """number
        MINUS? DIGIT+ (POINT DIGIT*)? """
        return float(ctx.getText())

    def visitFraction(self, ctx:parse.FractionContext):
        return Fraction(self.visit(ctx.expr(0)), self.visit(ctx.expr(1)))

    # Variable names and TeX symbols ===============================================
    def visitMultichar_var(self, ctx:parse.Multichar_varContext):
        """multichar_var
        (LETTER | DIGIT)+ """
        return ctx.getText()

    def visitVar_name_multichar(self, ctx:parse.Var_name_multicharContext):
        """var_name_multichar
        BACKTICK name=multichar_var BACKTICK """
        return self.visit(ctx.name)

    def visitTex_symb_single(self, ctx:parse.Tex_symb_singleContext):
        """tex_symb_single
        (LETTER | DIGIT) """
        return ctx.getText()

    def visitTex_symb_multi(self, ctx:parse.Tex_symb_multiContext):
        """tex_symb_multi
        LCURLY expr RCURLY """
        return self.visit(ctx.expr)

    def visitTex_symb_recurse(self, ctx:parse.Tex_symb_recurseContext):
        """tex_symb_recurse
        LCURLY var RCURLY """
        return self.visit(ctx.var)

    def visitVar(self, ctx:parse.VarContext):
        """var
        var_name (UNDERSCORE tex_symb)?
        var used to reference variable's value in an expression"""
        if ctx.tex_symb():
            return self.visit(ctx.var_name) + '_' + self.visit(ctx.tex_symb)
        return self.visit(ctx.var_name)


    # Variable and function assignments ========================================
    def visitVar_def(self, ctx:parse.Var_defContext):
        """var_def
        var_name (UNDERSCORE tex_symb)? 
        variable name used in assignment (as opposed to var)"""
        if ctx.tex_symb():
            return self.visit(ctx.var_name) + '_' + self.visit(ctx.tex_symb)
        return self.visit(ctx.var_name)

    def visitVar_assign(self, ctx:parse.Var_assignContext):
        """var_assign
        assign_var ASSIGN expr 
        assign a value to a variable in the state"""
        expr_eval = self.visit(ctx.expr)
        self.state[self.visit(ctx.var_def)] = expr_eval
        return expr_eval

    def visitFunc_assign(self, ctx:parse.Func_assignContext):
        """func_assign
        assign_var ASSIGN func_def 
        assign a value to a function in the state"""
        func_def = self.visit(ctx.func_def)
        self.state[self.visit(ctx.var_def)] = func_def
        return func_def

    # Function definitions ======================================================

    # Cases =====================================================================
    def visitCases_last_row(self, ctx:parse.Cases_last_rowContext):
        pass


def main(argv):
    stream = InputStream('5+6')
    lexer = LaTeXLexer(stream)
    tokens = CommonTokenStream(lexer)
    print(tokens.getText())
    parser = parse(tokens)
    tree = parser.entry()

    visitor = CastleVisitor()
    print(visitor.visit(tree))

if __name__ == '__main__':
    main(sys.argv)