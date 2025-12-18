import compilerTools.Token;
import java_cup.runtime.Symbol;
import java.util.ArrayList;

%%

%class Lexer
%implements java_cup.runtime.Scanner
%type Symbol
%public
%cup
%line
%column

%{
    public ArrayList<TError> lexerErrors = new ArrayList<>();
    
    // Bandera para controlar el punto y coma
    private boolean seEsperaPuntoYComa = false;

    // Estado de pánico SOLO para faltas de ';': si hay varias líneas seguidas sin ';',
    // reportamos SOLO la falta más baja (la última) cuando encontremos un punto de
    // sincronización (por ejemplo ';', '}', 'end' o EOF).
    private boolean panicFaltaPuntoYComa = false;
    private int panicSemiLine = 0;
    private int panicSemiColumn = 0;
    private boolean injectingSyntheticSemi = false;

    private void markMissingSemi(int line, int column) {
        panicFaltaPuntoYComa = true;
        panicSemiLine = line + 1;
        panicSemiColumn = column;
    }

    private void flushMissingSemiIfAny() {
        if (panicFaltaPuntoYComa) {
            String msg = "Error Léxico: Falta punto y coma ';' al final de la línea.";
            lexerErrors.add(new TError(panicSemiLine, panicSemiColumn, msg));
            panicFaltaPuntoYComa = false;
        }
    }

    // Cuando estamos en cabeceras que abren bloque (ej: program X {, metodo X(...) {,
    // rutina X(...) {, inicio {, cuando (...) {, mientras (...) {, sino {, loop { )
    // NO queremos exigir ';' al final de línea.
    private boolean enCabeceraBloque = false;

    private Symbol token(String lexeme, String lexicalComp, int line, int column, int symCode) {

        // Si venimos arrastrando faltas de ';', las reportamos solo cuando
        // llegamos a un punto de sincronización.
        if (!injectingSyntheticSemi && (symCode == sym.SEMI || symCode == sym.RBRACE || symCode == sym.END)) {
            flushMissingSemiIfAny();
        }

        // En cabeceras de bloque evitamos exigir ';' en saltos de línea.
        if (enCabeceraBloque) {
            seEsperaPuntoYComa = false;
        } else {
            // Tokens que finalizan una instrucción
            if (symCode == sym.ID || symCode == sym.NUMBER || symCode == sym.STRING || 
                symCode == sym.RPAREN || symCode == sym.RBRACK || 
                symCode == sym.TRUE || symCode == sym.FALSE || 
                symCode == sym.SALIR ||    
                symCode == sym.BRAKE ||    
                symCode == sym.STOP  ||    
                symCode == sym.REGRESA) { 

                seEsperaPuntoYComa = true;
            } else {
                seEsperaPuntoYComa = false;
            }
        }

        Token t = new Token(lexeme, lexicalComp, line + 1, column + 1);
        return new Symbol(symCode, line + 1, column + 1, t);
    }
%}

/* Macros */
LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace     = [ \t\f] 

Comment        = "//" {InputCharacter}* {LineTerminator}? | "/*" [^*]* ~"*/"

/* Identificadores y Literales */
Identifier     = [a-zA-Z_] [a-zA-Z0-9_]*
NumberLiteral  = [0-9]+ (\.[0-9]+)?

/* --- MACROS DE ERROR (PRIORIDAD) --- */
InvalidId      = [0-9]+ [a-zA-Z_] [a-zA-Z0-9_]*
MalformedNum   = [0-9]+ "." [0-9]* "." [0-9.]+
NumberWithText = [0-9]+ "." [a-zA-Z_]+

%%

/* 1. Comentarios y Espacios */
{Comment}       { /* Ignorar */ }
{WhiteSpace}    { /* Ignorar */ }

/* 2. Manejo del Salto de Línea (Punto y Coma) */
{LineTerminator} {
    if (seEsperaPuntoYComa) {
        // No dispares el error aquí: acumúlalo y reporta solo el último.
        markMissingSemi(yyline, yycolumn);
        seEsperaPuntoYComa = false;

        // Importante: inyectar un ';' sintético para que el parser NO arrastre
        // y no genere errores falsos (por ejemplo, errores de array por encontrar
        // ']' mucho después).
        injectingSyntheticSemi = true;
        Symbol s = token(";", "SEMI", yyline, yycolumn, sym.SEMI);
        injectingSyntheticSemi = false;
        return s;
    }
}

/* 3. MANEJO DE STRINGS Y ERRORES DE COMILLAS */

/* 3. MANEJO DE STRINGS Y ERRORES DE COMILLAS */
/* --- MANEJO DE STRINGS --- */

// REGLA 1: String Correcto (ESTA DEBE IR PRIMERO)
\"([^\\\"]|\\.)*\" { 
    return token(yytext(), "STRING", yyline, yycolumn, sym.STRING); 
}

// REGLA 2: Borra o comenta la regla que decía [^ \t\r\n\"]+ \"
// Esa regla es la que causa el error en salida("...")

// REGLA 3: Comilla de apertura sin cierre (Mantenla para detectar errores reales)
\" [^\"\n\r]* { 
    lexerErrors.add(new TError(yyline + 1, yycolumn, "Error Léxico: Comillas sin cerrar."));
    seEsperaPuntoYComa = false; 
    return token(yytext(), "STRING", yyline, yycolumn, sym.STRING);
}



/* 4. REGLAS DE ERROR ESPECÍFICAS */
{InvalidId} {
    lexerErrors.add(new TError(yyline + 1, yycolumn, "Error Léxico: Identificador inválido '" + yytext() + "'. No puede iniciar con número."));
    return token(yytext(), "ERROR", yyline, yycolumn, sym.error);
}

{MalformedNum} {
    lexerErrors.add(new TError(yyline + 1, yycolumn, "Error Léxico: Número mal formado '" + yytext() + "'. Demasiados puntos."));
    return token(yytext(), "ERROR", yyline, yycolumn, sym.error);
}

{NumberWithText} {
    lexerErrors.add(new TError(yyline + 1, yycolumn, "Error Léxico: Formato de número inválido '" + yytext() + "'."));
    return token(yytext(), "ERROR", yyline, yycolumn, sym.error);
}

/* 5. Estructura y Palabras Clave */
"program"       { enCabeceraBloque = true; return token(yytext(), "PROGRAM", yyline, yycolumn, sym.PROGRAM); }
"inicio"        { enCabeceraBloque = true; return token(yytext(), "INICIO", yyline, yycolumn, sym.INICIO); }
"end"           { return token(yytext(), "END", yyline, yycolumn, sym.END); }
"metodo"        { enCabeceraBloque = true; return token(yytext(), "METODO", yyline, yycolumn, sym.METODO); }
"rutina"        { enCabeceraBloque = true; return token(yytext(), "RUTINA", yyline, yycolumn, sym.RUTINA); }
"entrada"       { return token(yytext(), "ENTRADA", yyline, yycolumn, sym.ENTRADA); }
"salida"        { return token(yytext(), "SALIDA", yyline, yycolumn, sym.SALIDA); }
"regresa"       { return token(yytext(), "REGRESA", yyline, yycolumn, sym.REGRESA); }

/* Tipos, Control, Vehículo, Sensores */
"num"           { return token(yytext(), "NUM", yyline, yycolumn, sym.NUM); }
"bool"          { return token(yytext(), "BOOL", yyline, yycolumn, sym.BOOL); }
"str"           { return token(yytext(), "STR", yyline, yycolumn, sym.STR); }
"var"           { return token(yytext(), "VAR", yyline, yycolumn, sym.VAR); }
"const"         { return token(yytext(), "CONST", yyline, yycolumn, sym.CONST); }
"set"           { return token(yytext(), "SET", yyline, yycolumn, sym.SET); }
"true"          { return token(yytext(), "TRUE", yyline, yycolumn, sym.TRUE); }
"false"         { return token(yytext(), "FALSE", yyline, yycolumn, sym.FALSE); }
"cuando"        { enCabeceraBloque = true; return token(yytext(), "CUANDO", yyline, yycolumn, sym.CUANDO); }
"sino"          { enCabeceraBloque = true; return token(yytext(), "SINO", yyline, yycolumn, sym.SINO); }
"mientras"      { enCabeceraBloque = true; return token(yytext(), "MIENTRAS", yyline, yycolumn, sym.MIENTRAS); }
"loop"          { enCabeceraBloque = true; return token(yytext(), "LOOP", yyline, yycolumn, sym.LOOP); }
"salir"         { return token(yytext(), "SALIR", yyline, yycolumn, sym.SALIR); }
"sigue"         { return token(yytext(), "SIGUE", yyline, yycolumn, sym.SIGUE); }
"move"          { return token(yytext(), "MOVE", yyline, yycolumn, sym.MOVE); }
"turn"          { return token(yytext(), "TURN", yyline, yycolumn, sym.TURN); }
"stop"          { return token(yytext(), "STOP", yyline, yycolumn, sym.STOP); }
"wait"          { return token(yytext(), "WAIT", yyline, yycolumn, sym.WAIT); }
"accelerate"    { return token(yytext(), "ACCEL", yyline, yycolumn, sym.ACCEL); }
"decelerate"    { return token(yytext(), "DECEL", yyline, yycolumn, sym.DECEL); }
"reverse"       { return token(yytext(), "REVERSE", yyline, yycolumn, sym.REVERSE); }
"brake"         { return token(yytext(), "BRAKE", yyline, yycolumn, sym.BRAKE); }
"sensor"        { return token(yytext(), "SENSOR", yyline, yycolumn, sym.SENSOR); }
"gps"           { return token(yytext(), "GPS", yyline, yycolumn, sym.GPS); }
"speed"         { return token(yytext(), "SPEED", yyline, yycolumn, sym.SPEED); }
"distance"      { return token(yytext(), "DISTANCE", yyline, yycolumn, sym.DISTANCE); }
"obstacle"      { return token(yytext(), "OBSTACLE", yyline, yycolumn, sym.OBSTACLE); }
"broadcast"     { return token(yytext(), "BROADCAST", yyline, yycolumn, sym.BROADCAST); }
"receive"       { return token(yytext(), "RECEIVE", yyline, yycolumn, sym.RECEIVE); }
"message"       { return token(yytext(), "MESSAGE", yyline, yycolumn, sym.MESSAGE); }
"event"         { return token(yytext(), "EVENT", yyline, yycolumn, sym.EVENT); }
"on"            { return token(yytext(), "ON", yyline, yycolumn, sym.ON); }
"vehicle_id"    { return token(yytext(), "VEHICLE_ID", yyline, yycolumn, sym.VEHICLE_ID); }
"route"         { return token(yytext(), "ROUTE", yyline, yycolumn, sym.ROUTE); }
"waypoint"      { return token(yytext(), "WAYPOINT", yyline, yycolumn, sym.WAYPOINT); }
"goto"          { return token(yytext(), "GOTO", yyline, yycolumn, sym.GOTO); }
"map"           { return token(yytext(), "MAP", yyline, yycolumn, sym.MAP); }
"navigate"      { return token(yytext(), "NAVIGATE", yyline, yycolumn, sym.NAVIGATE); }
"destination"   { return token(yytext(), "DESTINATION", yyline, yycolumn, sym.DESTINATION); }

/* Operadores y Puntuación */
"=="            { return token(yytext(), "EQ", yyline, yycolumn, sym.EQ); }
"!="            { return token(yytext(), "NEQ", yyline, yycolumn, sym.NEQ); }
"<="            { return token(yytext(), "LE", yyline, yycolumn, sym.LE); }
">="            { return token(yytext(), "GE", yyline, yycolumn, sym.GE); }
"&&"            { return token(yytext(), "AND", yyline, yycolumn, sym.AND); }
"||"            { return token(yytext(), "OR", yyline, yycolumn, sym.OR); }
"+"             { return token(yytext(), "PLUS", yyline, yycolumn, sym.PLUS); }
"-"             { return token(yytext(), "MINUS", yyline, yycolumn, sym.MINUS); }
"*"             { return token(yytext(), "MUL", yyline, yycolumn, sym.MUL); }
"/"             { return token(yytext(), "DIV", yyline, yycolumn, sym.DIV); }
"%"             { return token(yytext(), "MOD", yyline, yycolumn, sym.MOD); }
"="             { return token(yytext(), "ASSIGN", yyline, yycolumn, sym.ASSIGN); }
"<"             { return token(yytext(), "LT", yyline, yycolumn, sym.LT); }
">"             { return token(yytext(), "GT", yyline, yycolumn, sym.GT); }
"!"             { return token(yytext(), "NOT", yyline, yycolumn, sym.NOT); }
";"             { return token(yytext(), "SEMI", yyline, yycolumn, sym.SEMI); }
","             { return token(yytext(), "COMMA", yyline, yycolumn, sym.COMMA); }
"["             { return token(yytext(), "LBRACK", yyline, yycolumn, sym.LBRACK); }
"]"             { return token(yytext(), "RBRACK", yyline, yycolumn, sym.RBRACK); }

"("             { return token(yytext(), "LPAREN", yyline, yycolumn, sym.LPAREN); }
")"             { return token(yytext(), "RPAREN", yyline, yycolumn, sym.RPAREN); }
"{"             { seEsperaPuntoYComa = false; enCabeceraBloque = false; return token(yytext(), "LBRACE", yyline, yycolumn, sym.LBRACE); }
"}"             { seEsperaPuntoYComa = false; return token(yytext(), "RBRACE", yyline, yycolumn, sym.RBRACE); }

// ------------------------------------------------------------------
// REGLA DEL PUNTO: Corregida para no causar cascada de errores léxicos
// ------------------------------------------------------------------
"."             { return token(yytext(), "POINT", yyline, yycolumn, sym.error); }

/* 6. Dinámicos */
{NumberLiteral} { return token(yytext(), "NUMBER", yyline, yycolumn, sym.NUMBER); }
{Identifier}    { return token(yytext(), "ID", yyline, yycolumn, sym.ID); }

/* 7. Error Genérico */
[^] { 
    if (!yytext().trim().isEmpty()) {
        lexerErrors.add(new TError(yyline + 1, yycolumn, "Error Léxico: Caracter inválido '" + yytext() + "'"));
        return token(yytext(), "ERROR", yyline, yycolumn, sym.error);
    }
}

<<EOF>> {
    // Si el archivo termina y aún estaba pendiente el ';', reporta el último.
    flushMissingSemiIfAny();
    return new Symbol(sym.EOF);
}