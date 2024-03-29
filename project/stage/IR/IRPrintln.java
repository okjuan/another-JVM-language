package IR;

import Type.*;

public class IRPrintln extends IRInstruction {
    Temp var;
    Type type;

    public IRPrintln(Temp var) {
        this.var = var;
        this.type = var.type;
    }

    public void accept(IR2Jasmin v) {
        v.visit(this);
    }

    public String toString() {
        return "PRINTLN" + AST2IRHelper.getIRTypeStr(type) + " " + this.var.toString() + ";";
    }
}