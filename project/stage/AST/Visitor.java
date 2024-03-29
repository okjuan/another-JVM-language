package AST;

import Type.*;

public interface Visitor {
//	public void visit (ArrayType a);
//	public void visit (ArrayAssignment s);
//	public void visit (ArrayReference a);
//	public void visit (Block b);
//	public void visit (BooleanLiteral b);
//	public void visit (CharacterLiteral c);
//	public void visit (DoStatement s);
//	public void visit (FloatLiteral f);	
    public void visit (FormalParameter p);
    public void visit (FormalParameterList params);
    public void visit (Function f);
    public void visit (FunctionBody f);
    public void visit (FunctionDecl f);
    public void visit (Identifier i);
//	public void visit (IdentifierValue v);
    public void visit (IfElseStatement s);
    public void visit (WhileStatement s);
    public void visit (StatementBlock b);
//  public void visit (IntegerLiteral i);
    public void visit (Expression e);
    public void visit (Program p);
    public void visit (Statement s);
//	public void visit (StringLiteral s);
    public void visit (Type t);
    public void visit (TypeNode t);
//	public void visit (VariableAssignment s);
    public void visit (VariableDeclaration v);
//	public void visit (WhileStatement s);
}

