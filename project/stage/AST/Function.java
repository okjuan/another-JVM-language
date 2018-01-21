package AST;

public class Function {
    FunctionDecl funcDecl;
    FunctionBody funcBody;

    public Function (FunctionDecl funcDecl, FunctionBody funcBody) {
        this.funcDecl = funcDecl;
        this.funcBody = funcBody;
    }

    public void accept (Visitor v) {
        v.visit(this);
        // System.out.println("Visiting: " + this);
    }

    /*
    public String toString () {
        return this.funcDecl.returnType.toString() + " " + this.funcDecl.name + " ( params here ) { }";
    }*/
}
