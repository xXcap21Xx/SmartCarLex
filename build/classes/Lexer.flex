import compilerTools.Token;
import java_cup.runtime.Symbol;
import compilerTools.ErrorLSSL;
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
    public ArrayList<ErrorLSSL> lexerErrors = new ArrayList<>();

    private Symbol token(String lexeme, String lexicalComp, int line, int column, int symCode) {
        Token t = new Token(lexeme, lexicalComp, line + 1, column + 1);
        return new Symbol(symCode, t);
    }
%}

/* Macros */
LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace     = {LineTerminator} | [ \t\f]
Comment        = "//" {InputCharacter}* {LineTerminator}? | "/*" [^*]* ~"*/"

/* Identificadores y Literales */
Identifier     = [a-zA-Z_] [a-zA-Z0-9_]*
NumberLiteral  = [0-9]+ (\.[0-9]+)?
StringLiteral  = \"([^\\\"]|\\.)*\"

%%

/* 1. Ignorar */
{WhiteSpace}    { /* Ignorar */ }
{Comment}       { /* Ignorar */ }

/* 2. Estructura Principal (Lo que pediste agregar) */
"program"       { return token(yytext(), "PROGRAM", yyline, yycolumn, sym.PROGRAM); }
"inicio"        { return token(yytext(), "INICIO", yyline, yycolumn, sym.INICIO); }
"end"           { return token(yytext(), "END", yyline, yycolumn, sym.END); }
"metodo"        { return token(yytext(), "METODO", yyline, yycolumn, sym.METODO); }
"rutina"        { return token(yytext(), "RUTINA", yyline, yycolumn, sym.RUTINA); }
"entrada"       { return token(yytext(), "ENTRADA", yyline, yycolumn, sym.ENTRADA); }
"salida"        { return token(yytext(), "SALIDA", yyline, yycolumn, sym.SALIDA); }
"regresa"       { return token(yytext(), "REGRESA", yyline, yycolumn, sym.REGRESA); }

/* 3. Tipos de Datos */
"num"           { return token(yytext(), "NUM", yyline, yycolumn, sym.NUM); }
"bool"          { return token(yytext(), "BOOL", yyline, yycolumn, sym.BOOL); }
"str"           { return token(yytext(), "STR", yyline, yycolumn, sym.STR); }
"var"           { return token(yytext(), "VAR", yyline, yycolumn, sym.VAR); }
"const"         { return token(yytext(), "CONST", yyline, yycolumn, sym.CONST); }
"set"           { return token(yytext(), "SET", yyline, yycolumn, sym.SET); }

/* 4. Control de Flujo */
"cuando"        { return token(yytext(), "CUANDO", yyline, yycolumn, sym.CUANDO); }
"sino"          { return token(yytext(), "SINO", yyline, yycolumn, sym.SINO); }
"mientras"      { return token(yytext(), "MIENTRAS", yyline, yycolumn, sym.MIENTRAS); }
"loop"          { return token(yytext(), "LOOP", yyline, yycolumn, sym.LOOP); }
"salir"         { return token(yytext(), "SALIR", yyline, yycolumn, sym.SALIR); }
"sigue"         { return token(yytext(), "SIGUE", yyline, yycolumn, sym.SIGUE); }

/* 5. Vehículo y Navegación */
"move"          { return token(yytext(), "MOVE", yyline, yycolumn, sym.MOVE); }
"turn"          { return token(yytext(), "TURN", yyline, yycolumn, sym.TURN); }
"stop"          { return token(yytext(), "STOP", yyline, yycolumn, sym.STOP); }
"wait"          { return token(yytext(), "WAIT", yyline, yycolumn, sym.WAIT); }
"accelerate"    { return token(yytext(), "ACCEL", yyline, yycolumn, sym.ACCEL); }
"decelerate"    { return token(yytext(), "DECEL", yyline, yycolumn, sym.DECEL); }
"reverse"       { return token(yytext(), "REVERSE", yyline, yycolumn, sym.REVERSE); }
"brake"         { return token(yytext(), "BRAKE", yyline, yycolumn, sym.BRAKE); }

"route"         { return token(yytext(), "ROUTE", yyline, yycolumn, sym.ROUTE); }
"waypoint"      { return token(yytext(), "WAYPOINT", yyline, yycolumn, sym.WAYPOINT); }
"goto"          { return token(yytext(), "GOTO", yyline, yycolumn, sym.GOTO); }
"map"           { return token(yytext(), "MAP", yyline, yycolumn, sym.MAP); }
"navigate"      { return token(yytext(), "NAVIGATE", yyline, yycolumn, sym.NAVIGATE); }
"destination"   { return token(yytext(), "DESTINATION", yyline, yycolumn, sym.DESTINATION); }

/* 6. Sensores y Comunicación */
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

/* 7. Operadores y Signos */
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
"("             { return token(yytext(), "LPAREN", yyline, yycolumn, sym.LPAREN); }
")"             { return token(yytext(), "RPAREN", yyline, yycolumn, sym.RPAREN); }
"{"             { return token(yytext(), "LBRACE", yyline, yycolumn, sym.LBRACE); }
"}"             { return token(yytext(), "RBRACE", yyline, yycolumn, sym.RBRACE); }
"["             { return token(yytext(), "LBRACK", yyline, yycolumn, sym.LBRACK); }
"]"             { return token(yytext(), "RBRACK", yyline, yycolumn, sym.RBRACK); }

/*7.5. True y False*/
"true"          { return token(yytext(), "TRUE", yyline, yycolumn, sym.TRUE); }
"false"          { return token(yytext(), "FALSE", yyline, yycolumn, sym.FALSE); }

/* 8. Dinámicos */
{NumberLiteral} { return token(yytext(), "NUMBER", yyline, yycolumn, sym.NUMBER); }
{StringLiteral} { return token(yytext(), "STRING", yyline, yycolumn, sym.STRING); }
{Identifier}    { return token(yytext(), "ID", yyline, yycolumn, sym.ID); }

. {
    // Guardamos el error en la lista antes de devolver el token
    lexerErrors.add(new ErrorLSSL(yyline+1, yycolumn+1, "Error Léxico: Caracter no reconocido '" + yytext() + "'"));
    return token(yytext(), "ERROR", yyline, yycolumn, sym.ERROR);
}