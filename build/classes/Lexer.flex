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
    
    // --- NUEVO: Bandera para controlar el punto y coma ---
    private boolean seEsperaPuntoYComa = false;

private Symbol token(String lexeme, String lexicalComp, int line, int column, int symCode) {
        
        // Caso 1: Tokens que finalizan una instrucción
        if (symCode == sym.ID || symCode == sym.NUMBER || symCode == sym.STRING || 
            symCode == sym.RPAREN || symCode == sym.RBRACK || 
            symCode == sym.TRUE || symCode == sym.FALSE || 
            
            // --- CORRECCIÓN AQUÍ ---
            symCode == sym.SALIR ||    // Antes era BREAK
            symCode == sym.BRAKE ||    // El comando de frenar
            symCode == sym.STOP  ||    // El comando de parar
            // -----------------------

            symCode == sym.REGRESA) { 
            
            seEsperaPuntoYComa = true;
        } 
        else {
            seEsperaPuntoYComa = false;
        }

        Token t = new Token(lexeme, lexicalComp, line + 1, column + 1);
        // Recuerda usar el constructor de 4 parámetros que arreglamos antes
        return new Symbol(symCode, line + 1, column + 1, t);
    }
%}

/* Macros */
LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]

/* OJO: Quitamos LineTerminator de WhiteSpace para manejarlo manualmente */
WhiteSpace     = [ \t\f] 

Comment        = "//" {InputCharacter}* {LineTerminator}? | "/*" [^*]* ~"*/"

/* Identificadores y Literales */
Identifier     = [a-zA-Z_] [a-zA-Z0-9_]*
NumberLiteral  = [0-9]+ (\.[0-9]+)?
StringLiteral  = \"([^\\\"]|\\.)*\"

%%

/* 1. Comentarios (Ignorar) */
{Comment}       { /* Ignorar, no afecta al punto y coma */ }

/* 2. Espacios en blanco (Ignorar) */
{WhiteSpace}    { /* Ignorar */ }

/* 3. --- NUEVO: Manejo del Salto de Línea para detectar error --- */
{LineTerminator} {
    if (seEsperaPuntoYComa) {
        // ¡ERROR DETECTADO EN EL LEXER!
        String msg = "Error Léxico: Falta punto y coma ';' al final de la línea.";
        lexerErrors.add(new TError(yyline + 1, yycolumn, msg)); 
        
        // Reseteamos para no spamear errores
        seEsperaPuntoYComa = false; 
    }
    // No retornamos nada, solo consumimos el salto de línea
}

/* 4. Estructura y Palabras Clave */
"program"       { return token(yytext(), "PROGRAM", yyline, yycolumn, sym.PROGRAM); }
"inicio"        { return token(yytext(), "INICIO", yyline, yycolumn, sym.INICIO); }
"end"           { return token(yytext(), "END", yyline, yycolumn, sym.END); }
"metodo"        { return token(yytext(), "METODO", yyline, yycolumn, sym.METODO); }
"rutina"        { return token(yytext(), "RUTINA", yyline, yycolumn, sym.RUTINA); }
"entrada"       { return token(yytext(), "ENTRADA", yyline, yycolumn, sym.ENTRADA); }
"salida"        { return token(yytext(), "SALIDA", yyline, yycolumn, sym.SALIDA); }
"regresa"       { return token(yytext(), "REGRESA", yyline, yycolumn, sym.REGRESA); }

/* Tipos */
"num"           { return token(yytext(), "NUM", yyline, yycolumn, sym.NUM); }
"bool"          { return token(yytext(), "BOOL", yyline, yycolumn, sym.BOOL); }
"str"           { return token(yytext(), "STR", yyline, yycolumn, sym.STR); }
"var"           { return token(yytext(), "VAR", yyline, yycolumn, sym.VAR); }
"const"         { return token(yytext(), "CONST", yyline, yycolumn, sym.CONST); }
"set"           { return token(yytext(), "SET", yyline, yycolumn, sym.SET); }
"true"          { return token(yytext(), "TRUE", yyline, yycolumn, sym.TRUE); }
"false"         { return token(yytext(), "FALSE", yyline, yycolumn, sym.FALSE); }

/* Control */
"cuando"        { return token(yytext(), "CUANDO", yyline, yycolumn, sym.CUANDO); }
"sino"          { return token(yytext(), "SINO", yyline, yycolumn, sym.SINO); }
"mientras"      { return token(yytext(), "MIENTRAS", yyline, yycolumn, sym.MIENTRAS); }
"loop"          { return token(yytext(), "LOOP", yyline, yycolumn, sym.LOOP); }
"salir"         { return token(yytext(), "SALIR", yyline, yycolumn, sym.SALIR); }
"sigue"         { return token(yytext(), "SIGUE", yyline, yycolumn, sym.SIGUE); }

/* Vehículo */
"move"          { return token(yytext(), "MOVE", yyline, yycolumn, sym.MOVE); }
"turn"          { return token(yytext(), "TURN", yyline, yycolumn, sym.TURN); }
"stop"          { return token(yytext(), "STOP", yyline, yycolumn, sym.STOP); }
"wait"          { return token(yytext(), "WAIT", yyline, yycolumn, sym.WAIT); }
"accelerate"    { return token(yytext(), "ACCEL", yyline, yycolumn, sym.ACCEL); }
"decelerate"    { return token(yytext(), "DECEL", yyline, yycolumn, sym.DECEL); }
"reverse"       { return token(yytext(), "REVERSE", yyline, yycolumn, sym.REVERSE); }
"brake"         { return token(yytext(), "BRAKE", yyline, yycolumn, sym.BRAKE); }

/* Sensores y Comms */
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

/* Navegación */
"route"         { return token(yytext(), "ROUTE", yyline, yycolumn, sym.ROUTE); }
"waypoint"      { return token(yytext(), "WAYPOINT", yyline, yycolumn, sym.WAYPOINT); }
"goto"          { return token(yytext(), "GOTO", yyline, yycolumn, sym.GOTO); }
"map"           { return token(yytext(), "MAP", yyline, yycolumn, sym.MAP); }
"navigate"      { return token(yytext(), "NAVIGATE", yyline, yycolumn, sym.NAVIGATE); }
"destination"   { return token(yytext(), "DESTINATION", yyline, yycolumn, sym.DESTINATION); }

/* Operadores (Estos resetean la bandera automáticamente en el 'else' del token()) */
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

/* Puntuación */
";"             { return token(yytext(), "SEMI", yyline, yycolumn, sym.SEMI); }
","             { return token(yytext(), "COMMA", yyline, yycolumn, sym.COMMA); }
"("             { return token(yytext(), "LPAREN", yyline, yycolumn, sym.LPAREN); }
")"             { return token(yytext(), "RPAREN", yyline, yycolumn, sym.RPAREN); } // <- Este activa la bandera en el if del token()
"{"             { seEsperaPuntoYComa = false; return token(yytext(), "LBRACE", yyline, yycolumn, sym.LBRACE); }
"}"             { seEsperaPuntoYComa = false; return token(yytext(), "RBRACE", yyline, yycolumn, sym.RBRACE); }
"["             { return token(yytext(), "LBRACK", yyline, yycolumn, sym.LBRACK); }
"]"             { return token(yytext(), "RBRACK", yyline, yycolumn, sym.RBRACK); }

/* Dinámicos (Estos activan la bandera) */
{NumberLiteral} { return token(yytext(), "NUMBER", yyline, yycolumn, sym.NUMBER); }
{StringLiteral} { return token(yytext(), "STRING", yyline, yycolumn, sym.STRING); }
{Identifier}    { return token(yytext(), "ID", yyline, yycolumn, sym.ID); }

/* Errores */
. {
    lexerErrors.add(new TError(yyline+1, yycolumn+1, "Error Léxico: Caracter inválido '" + yytext() + "'"));
    return token(yytext(), "ERROR", yyline, yycolumn, sym.ERROR);
}

// 1. Cadena VÁLIDA: Se abre y cierra en la misma línea
\" [^\"\n\r]* \" { 
    return token(yytext(), "STRING", yyline, yycolumn, sym.STRING); 
}

// 2. ERROR: Cadena sin cerrar. 
// IMPORTANTE: El [^\"\n\r\)\;]* impide que el error se coma el ')' y el ';'
\" [^\"\n\r\)\;]* { 
    String msg = "Error Léxico: Comillas sin cerrar en esta línea";
    lexerErrors.add(new TError(yyline + 1, yycolumn, msg));
    
    // Devolvemos un STRING para que el Parser crea que la función está completa
    // y pueda encontrar el ')' y el ';' que dejamos libres.
    return token(yytext(), "STRING", yyline, yycolumn, sym.STRING);
}

[^] { 
    // Captura CUALQUIER carácter que no haya coincidido con las reglas de arriba
    // EXCEPTO espacios y saltos de línea que ya deben estar gestionados
    if (!yytext().trim().isEmpty()) {
        lexerErrors.add(new TError(yyline + 1, yycolumn, "Error Léxico: Caracter inválido '" + yytext() + "'"));
    }
}