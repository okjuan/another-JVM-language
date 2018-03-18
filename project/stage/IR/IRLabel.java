package IR;

import IR.IRInstruction;

public class IRLabel extends IRInstruction {
    int id;

    public IRLabel(int id) {
        this.id = id;
    }

    // NOTE: this method would be removed if a new IRLabelInstruction class is created
    public String labelStr() {
        return "L" + this.id;
    }

    public String toString() {
        return "L" + this.id + ":;";
    }
}