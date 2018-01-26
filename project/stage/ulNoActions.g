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
    :
    (f=function { prog.addElement(f);})+ EOF;

function returns [Function f]
        :
        fd=functionDecl fb=functionBody
        { f = new Function(fd,fb); }
    ;

functionDecl returns [FunctionDecl fd]
        :
        cType=compoundType id=identifier '(' params=formalParams ')'
        { fd = new FunctionDecl(cType, id, params); }
    ;

functionBody returns [FunctionBody fb]
        @init { fb = new FunctionBody(); }
        : '{' (
            vd=varDecl { fb.addVarDecl(vd); }
        )*
        (
            s=statement
        )* '}'
    ;

formalParams returns [FormalParameterList params]
        @init { params = new FormalParameterList(); }
        : cType=compoundType id=identifier
        { params.addElement(new FormalParameter(cType, id)); }
        ( param=moreFormals { params.addElement(param); } )*
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
        : ';'
        | expr ';'
        | PRINT expr ';'
        | PRINTLN expr ';'
        | RETURN expr? ';'
        | ifStatement
        | WHILE '(' expr ')' block
        | identifier EQUALS expr ';'
        | identifier '[' expr ']' EQUALS expr ';'
    ;

ifStatement options {backtrack=true;}
        : IF '(' expr ')' block ELSE block
        | IF '(' expr ')' block
    ;

block: '{' statement* '}';

expr: lessThanExpr ('==' lessThanExpr)*;

lessThanExpr: addExpr ('<' addExpr)*;

addExpr: multExpr (('+'|'-') multExpr)*;

multExpr: exprAtom ('*' exprAtom)*;

exprAtom
        : identifier '(' exprList ')'
        | identifier '[' expr ']'
        | identifier
        | literal
        | '(' expr ')'
    ;

exprList
        : expr exprMore*
        |
    ;

exprMore: ',' expr;

compoundType returns [TypeNode cType]
        : TYPE { cType = new TypeNode(this.getTypeInstance($TYPE.text)); }
        | TYPE '[' INTCONSTANT ']'
        {
            int size = Integer.parseInt($INTCONSTANT.text);
            Type elementType = this.getTypeInstance($TYPE.text);
            cType = new TypeNode(new ArrayType(elementType, size));
        }
    ;

literal
        : 'true'
        | 'false'
        | INTCONSTANT
        | FLOATCONSTANT
        | CHARCONSTANT
        | STRINGCONSTANT
    ;

identifier returns [Identifier id]
        : ID { id = new Identifier($ID.text); }
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
