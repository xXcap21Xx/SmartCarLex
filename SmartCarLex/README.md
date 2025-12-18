# SmartCarLex
Compilador lexico y sintactico para la automatizacion de un automovil autonomo



NOTA IMPORTANTE!!!!
Puede que que de error al momento de modificar los LexerColor y Lexer, para solucionarlo solo debemos de modificar el codigo.

en el LexerColor.java:

    public Yytoken yylex() throws java.io.IOException
  
por esto:

    public TextColor yylex() throws java.io.IOException
    
y en el Lexer.java solo debemos de modificar en el sym.java:

    public static final int error = 1;

por esto:

    public static final int ERROR = 1;

en el mismo Lexer.java, tenemos que modificar esta linea de codigo:

    public class Lexer implements java_cup.runtime.Scanner, java_cup.runtime.Scanner {

por esto(Solo es borrar el ,java_cup.runtime.Scanner que esta de mas):

    public class Lexer implements java_cup.runtime.Scanner{

Ahora, para poder moficar el Parser.cup y el sym.java debemos de poner este comando en la terminal de VSCode o de CMD
    
    java -jar java-cup-11b.jar -parser Parser -symbols sym c:LaRutaDondeTengasElProyecto\GitHub\SmartCarLex\src\Parser.cup

y modificara/creara los archivos.java (Sym.java y Parser.java). OJO!!!, los archivos los crea en raiz del proyecto, solo muevanlos a la carpeta src y todo se arregla (reemplacenlos con los que ya existen)
