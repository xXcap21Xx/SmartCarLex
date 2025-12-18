package compilerTools;

import java.util.ArrayList;
import java.util.List;

public class ASTNode {
    public String label;
    public List<ASTNode> children = new ArrayList<>();

    public ASTNode(String label) {
        this.label = label;
    }

    public void addChild(ASTNode child) {
        children.add(child);
    }
}
