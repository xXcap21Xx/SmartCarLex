# SmartCarLex
Compilador lexico y sintactico para la automatizacion de un automovil autonomo



NOTA IMPORTANTE!!!!
Puede que que de error al momento de modificar los LexerColor y Lexer, para solucionarlo solo debemos de modificar la linea de codigo en el LexerColor.java:
  public Yytoken yylex() throws java.io.IOException
  
por esto:
    public TextColor yylex() throws java.io.IOException
    
y en el Lexer.java solo debemos de modificar en el sym.java:
    public static final int error = 1;

por esto:
    public static final int ERROR = 1;
