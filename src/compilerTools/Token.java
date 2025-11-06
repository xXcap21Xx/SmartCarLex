package compilerTools;

public class Token {
    private final String lexeme;
    private final String type;
    private final int line;
    private final int column;

    public Token(String lexeme, String type, int line, int column) {
        this.lexeme = lexeme;
        this.type   = type;
        this.line   = line;
        this.column = column;
    }

    public String getLexeme() {
        return lexeme;
    }

    public String getType() {
        return type;
    }

    public int getLine() {
        return line;
    }

    public int getColumn() {
        return column;
    }
    
    public String getLexicalComp(){
        return type;
    }

    @Override
    public String toString() {
        return String.format("%s('%s') @ %d:%d", type, lexeme, line, column);
    }
}
