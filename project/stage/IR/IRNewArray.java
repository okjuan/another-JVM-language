package IR;

import Type.*;

public class IRNewArray extends IRExpression {
    Type type;
    int size;

    public IRNewArray(Type type, int size) {
        this.type = type;
        this.size = size;
    }

    public void accept(IR2Jasmin v) {
        v.visit(this);
    }

    public String toString() {
        String typeIRString = AST2IRHelper.getIRTypeStr(this.type.getElementType());
        return "NEWARRAY " + typeIRString + " " + this.size;
    }
}