grammar ulNoActions;
@header
{
    import AST.*;
    import Type.*;
    import java.util.List;
    import java.util.ArrayList;
}

@members
{
    public Type getTypeInstance(String typeName) {
        Type type = null;
        switch(typeName) {
            case("int"):
                type = new IntegerType(); break;
            case("string"):
                type = new StringType(); break;
            case("float"):
                type = new FloatType(); break;
            case("void"):
                type = new VoidType(); break;
            case("char"):
                type = new CharType(); break;
            case("boolean"):
                type = new BooleanType(); break;
            default:
                System.out.println("ERROR in compoundType rule: do not recognize "+typeName+" as a type"); break;
        }
        return type;
    }
    protected void mismatch (IntStream input, int ttype, BitSet follow)
            throws RecognitionException
    {
            throw new MismatchedTokenException(ttype, input);
    }
    public void recoverFromMismatchedSet (IntStream input,
                                          RecognitionException e,
                                          BitSet follow)
            throws RecognitionException
    {
            reportError(e);
            throw e;
    }
}

@rulecatch {
        catch (RecognitionException ex) {
                reportError(ex);
                throw ex;
        }
}

program returns [Program prog]
        @init { prog = new Program(); }
        : (
            f=function { prog.addElement(f);}
        )+ EOF
    ;

function returns [Function f]
        : fd=functionDecl fb=functionBody
        { f = new Function(fd,fb); }
    ;

functionDecl returns [FunctionDecl fd]
        : cType=compoundType id=identifier '(' params=formalParams ')'
        { fd = new FunctionDecl(cType, id, params); }
    ;

functionBody returns [FunctionBody fb]
        @init { fb = new FunctionBody(); }
        : '{'
            (vd=varDecl { fb.addVarDecl(vd); })*
            (s=statement { fb.addStatement(s); })*
        '}'
    ;

formalParams returns [FormalParameterList params]
        @init { params = new FormalParameterList(); }

        : cType=compoundType id=identifier
        { params.addElement(new FormalParameter(cType, id)); }
        (
            param=moreFormals { params.addElement(param); }
        )*

        // empty params allowed as well
        |
    ;

moreFormals returns [FormalParameter param]
        : ',' cType=compoundType id=identifier
        { param = new FormalParameter(cType, id); }
    ;

varDecl returns [VariableDeclaration varDecl]
        : ctype=compoundType id=identifier ';'
        { varDecl = new VariableDeclaration(ctype, id); }
    ;

statement returns [Statement s] options {backtrack=true;}
        : ';' { s = new EmptyStatement(); }

        | e=expr ';'
        { s = new ExpressionStatement(e); }

        | PRINT e=expr ';'
        { s = new PrintStatement(e); }

        | PRINTLN e=expr ';'
        { s = new PrintlnStatement(e); }

        | RETURN e=expr? ';'
        { s = new ReturnStatement(e); }

        | condStatement=ifStatement
        { s = condStatement; }

        | WHILE '(' cond=expr ')' loopBody=block
        { s = new WhileStatement(cond, loopBody); }

        | id=identifier EQUALS e=expr ';'
        { s = new ScalarAssignmentStatement(id, e); }

        | id=identifier '[' indexExpr=expr ']' EQUALS e=expr ';'
        { s = new ArrayAssignmentStatement(id, indexExpr, e); }
    ;

ifStatement returns [IfElseStatement condStatement] options {backtrack=true;}
        : IF '(' cond=expr ')' ifBlock=block ELSE elseBlock=block
        { condStatement = new IfElseStatement(cond, ifBlock, elseBlock); }

        | IF '(' cond=expr ')' ifBlock=block
        { condStatement = new IfElseStatement(cond, ifBlock); }
    ;

block returns [StatementBlock b]
        @init { b = new StatementBlock(); }
        : '{'
            (s=statement { b.addStatement(s); })*
        '}'
    ;

expr returns [Expression e]
        : leftExpr=lessThanExpr { e = leftExpr; }
        (
            '==' rightExpr=lessThanExpr { e = new EqualityExpression(e, rightExpr); }
        )*
    ;

lessThanExpr returns [Expression e]
        : leftExpr=addExpr { e = leftExpr; }
        (
            '<' leftExpr=addExpr { e = new LessThanExpression(e, leftExpr); }
        )*
    ;

addExpr returns [Expression e]
        : leftExpr=multExpr { e = leftExpr; }
        (
            op=('+'|'-') rightExpr=multExpr
            {
                e = ($op.text.equals("+")?
                    new AddExpression(e, rightExpr) :
                    new SubtractExpression(e, rightExpr)
                );
            }
        )*
    ;

multExpr returns [Expression e]
        : leftAtom=exprAtom { e = leftAtom; }
        (
            '*' rightAtom=exprAtom { e = new MultExpression(e, rightAtom); }
        )*
    ;

exprAtom returns [Expression e]
        : id=identifier '(' args=exprList ')'
        { e = new FunctionCallExpression(id, args); }

        | id=identifier '[' idExpr=expr ']'
        { e = new ArrayExpression(id, idExpr); }

        | id=identifier
        { e = new IdentifierExpression(id, id.getLineNumber(), id.getLinePos()); }

        | lit=literal { e=lit; }

        | '(' parenExpr=expr ')'
        { e = new ParenExpression(parenExpr); }
    ;

exprList returns [ExpressionList args]
        @init { args = new ExpressionList(); }

        : arg1=expr { args.addElement(arg1); }
        (argN=exprMore { args.addElement(argN); })*

        // empty args allowed as well
        |
    ;

exprMore returns [Expression e]
        : ',' temp=expr { e = temp; }
    ;

compoundType returns [TypeNode cType]
        : TYPE { cType = new TypeNode(this.getTypeInstance($TYPE.text), $TYPE.line, $TYPE.pos); }
        | TYPE '[' INTCONSTANT ']'
        {
            int size = Integer.parseInt($INTCONSTANT.text);
            Type elementType = this.getTypeInstance($TYPE.text);
            cType = new TypeNode(new ArrayType(elementType, size), $TYPE.line, $TYPE.pos);
        }
    ;

literal returns [Expression e]
        : BOOLCONSTANT
        {
            e = new LiteralExpression(
                new BooleanType(),
                Boolean.parseBoolean($BOOLCONSTANT.text),
                $BOOLCONSTANT.line,
                $BOOLCONSTANT.pos
            );
        }

        | INTCONSTANT
        {
            e = new LiteralExpression(
                new IntegerType(),
                Integer.parseInt($INTCONSTANT.text),
                $INTCONSTANT.line,
                $INTCONSTANT.pos
            );
        }

        | FLOATCONSTANT
        {
            e = new LiteralExpression(
                new FloatType(),
                Float.parseFloat($FLOATCONSTANT.text),
                $FLOATCONSTANT.line,
                $FLOATCONSTANT.pos
            );
        }

        | CHARCONSTANT
        // the character exists at index=1 e.g. $CHARCONSTANT.text="'c'"
        {
            e = new LiteralExpression(
                new CharType(),
                $CHARCONSTANT.text.charAt(1),
                $CHARCONSTANT.line,
                $CHARCONSTANT.pos
            );
        }

        | STRINGCONSTANT
        {
            e = new LiteralExpression(
                new StringType(),
                $STRINGCONSTANT.text,
                $STRINGCONSTANT.line,
                $STRINGCONSTANT.pos
            );
        }
    ;

identifier returns [Identifier id]
        : ID { id = new Identifier($ID.text, $ID.line, $ID.pos); }
    ;

/* Lexer */

IF: 'if';

ELSE: 'else';

WHILE: 'while';

PRINT: 'print';

PRINTLN: 'println';

RETURN: 'return';

EQUALS: '=';

TYPE
        : 'int'
        | 'float'
        | 'char'
        | 'string'
        | 'boolean'
        | 'void'
    ;

BOOLCONSTANT: 'true' | 'false';

ID: ('a'..'z' | 'A'..'Z' | '_')('a'..'z' | 'A'..'Z' | '_' | DIGIT)*;

CHARCONSTANT: '\''('a'..'z' | 'A'..'Z' | '_' | ' ' | DIGIT)'\'';

STRINGCONSTANT: '\"'('a'..'z' | 'A'..'Z' | '_' | ' ' | DIGIT)*'\"';

INTCONSTANT: DIGIT+;

FLOATCONSTANT: DIGIT+ '.' DIGIT+;

/* These two lines match whitespace and comments
 * and ignore them.
 * You want to leave these as last in the file.
 * Add new lexical rules above
 */
WS: ( '\t' | ' ' | ('\r' | '\n') )+ { $channel = HIDDEN;};

COMMENT: '//' ~('\r' | '\n')* ('\r' | '\n') { $channel = HIDDEN;};

fragment DIGIT: '0'..'9';
