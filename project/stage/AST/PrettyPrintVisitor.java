package AST;

import Type.*;

public class PrettyPrintVisitor implements Visitor {
    private final int INDENTSIZE = 4;
    int indentLevel;

    public PrettyPrintVisitor() {
        this.indentLevel = 0;
    }

    public void visit (Program prog) {
        String delimiter = "";
        for (Function func : prog.functionList) {
            System.out.print(delimiter);
            func.accept(this);
            delimiter = "\n";
        }
    }

    public void visit (Function func) {
        func.funcDecl.accept(this);
        func.funcBody.accept(this);
    }

    public void visit (FunctionDecl fd) {
        println (fd.toString());
    }

    public void visit (FunctionBody fb) {
        println ("{");
        indentLevel++;
        for (VariableDeclaration varDecl : fb.varDecls) {
            varDecl.accept(this);
        }
        if (fb.varDecls.size() > 0) System.out.println("");
        for (Statement s : fb.statements) {
            s.accept(this);
        }
        indentLevel--;
        println ("}");
    }

    public void visit (VariableDeclaration varDecl) {
        println (varDecl.toString());
    }

    public void visit(Statement s) {
        println(s.toString());
    }

    public void visit(Expression e) {
        println(e.toString());
    }

    public void visit(IfElseStatement s) {
        println("if (" + s.cond.toString() + ")");
        s.ifBlock.accept(this);
        if (s.elseBlock != null) {
            println("else");
            s.elseBlock.accept(this);
        }
    }

    public void visit(WhileStatement s) {
        println("while (" + s.cond.toString() + ")");
        s.loopBody.accept(this);
    }

    public void visit(StatementBlock b) {
        println ("{");
        indentLevel++;
        for (Statement s : b.statements) {
            s.accept(this);
        }
        indentLevel--;
        println ("}");
    }

    public void visit (FormalParameterList params) { }

    public void visit (FormalParameter param) { }

    public void visit (TypeNode typeNode) { }

    public void visit (Type t) { }

    public void visit (Identifier id) { }

    // change arg to ASTNode, making toString() implicit
    private void println (String line) {
        int numSpaces = this.INDENTSIZE * this.indentLevel;
        // https://stackoverflow.com/questions/1235179/simple-way-to-repeat-a-string-in-java/4903603#4903603
        String indentation = new String(new char[numSpaces]).replace("\0", " ");
        System.out.println(indentation + line);

    }
}
