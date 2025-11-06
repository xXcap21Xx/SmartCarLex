package compilerTools;

public class ErrorLSSL {
    private final int line;
    private final int column;
    private final String message;

    public ErrorLSSL(int line, int column, String message) {
        this.line   = line;
        this.column = column;
        this.message = message;
    }

    public int getLine() {
        return line;
    }

    public int getColumn() {
        return column;
    }

    public String getMessage() {
        return message;
    }

    @Override
    public String toString() {
        return "[" + line + ":" + column + "] " + message;
    }
}
