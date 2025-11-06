import compilerTools.Token;
import java_cup.runtime.Symbol;

%%

%class Lexer
%implements java_cup.runtime.Scanner
%type Symbol
%cup
%line
%column

%{

    /**
     * Crea un Token interno (para tu AST o para mostrar) y lo envuelve en un Symbol de CUP.
     * symCode debe coincidir exactamente con el nombre del terminal en sym.java (generado por CUP).
     */
    private Symbol token(String lexeme, String lexicalComp, int line, int column, int symCode) {
        Token t = new Token(lexeme, lexicalComp, line + 1, column + 1);
        return new Symbol(symCode, t);
    }

%}

/* ----------------- Macros / Definiciones ----------------- */

LineTerminator     = \r|\n|\r\n
InputCharacter     = [^\r\n]
WhiteSpace         = {LineTerminator} | [ \t\f]

/* comments */
TraditionalComment = "/*" [^*]* ~"*/" | "/*" "*"+ "/"
EndOfLineComment   = "//" {InputCharacter}* {LineTerminator}?
Comment            = {TraditionalComment} | {EndOfLineComment}

/* Identifiers */
Identifier         = [a-zA-Z] [a-zA-Z0-9]*

/* Literals */
IntegerLiteral     = 0 | [1-9][0-9]*            // Decimales
FloatLiteral       = {IntegerLiteral}"."[0-9]+  // Flotantes
/*Number             = {FloatLiteral} | {IntegerLiteral}*/

/* Operators */
Plus               = "\+"
Minus              = "\-"
Multiply           = "\*"
Divide             = "/"
Power              = "\^"
GT                 = ">"
LT                 = "<"
GE                 = ">="
LE                 = "<="
EQ                 = "=="
NE                 = "!="
/*SquareRoot         = "sqrt"*/

/* Grouping */
LeftParen          = "\("
RightParen         = "\)"

LeftBrace           = "{"
RightBrace          = "}"

/* Reserved Words (reconocidos como tokens distintos si querés efectos semánticos) */
/*
ADD                = "\+"
SUB                = "\-"
DIV                = "/"
MUL                = "*"
*/
SIN                = "SIN"
PI                 = "PI"
SQRT               = "sqrt"

/* Estructuras de codigo */
IF      = "if"
ELSE    = "else"
FOR     = "for"

/* Otros */
Assignment         = "="
Comma              = ","
Semicolon          = ";" 

%%

/* ----------------- Reglas de Tokens ----------------- */

{Comment}         { /* Ignorar comentarios */ }

{WhiteSpace}      { /* Ignorar espacios y saltos de línea */ }

/*
{ADD}             { return token(yytext(), "ADD", yyline, yycolumn, sym.ADD); }
{SUB}             { return token(yytext(), "SUB", yyline, yycolumn, sym.SUB); }
{DIV}             { return token(yytext(), "DIV", yyline, yycolumn, sym.DIV); }
{MUL}             { return token(yytext(), "MUL", yyline, yycolumn, sym.MUL); }
*/
{SIN}             { return token(yytext(), "SIN", yyline, yycolumn, sym.SIN); }
{PI}              { return token(yytext(), "PI", yyline, yycolumn, sym.PI); }
{SQRT}            { return token(yytext(), "SQRT", yyline, yycolumn, sym.SQRT); }
{IF}              { return token(yytext(), "IF", yyline, yycolumn, sym.IF); }
{ELSE}            { return token(yytext(), "ELSE", yyline, yycolumn, sym.ELSE); }
{FOR}             { return token(yytext(), "FOR", yyline, yycolumn, sym.FOR); }

{FloatLiteral}    { return token(yytext(), "FLOAT_LITERAL", yyline, yycolumn, sym.FLOAT_LITERAL); }
{IntegerLiteral}  { return token(yytext(), "INTEGER_LITERAL", yyline, yycolumn, sym.INTEGER_LITERAL); }

{Identifier}      { return token(yytext(), "IDENTIFIER", yyline, yycolumn, sym.IDENTIFIER); }

{Plus}            { return token(yytext(), "PLUS", yyline, yycolumn, sym.PLUS); }
{Minus}           { return token(yytext(), "MINUS", yyline, yycolumn, sym.MINUS); }
{Multiply}        { return token(yytext(), "MULTIPLY", yyline, yycolumn, sym.MUL); }
{Divide}          { return token(yytext(), "DIVIDE", yyline, yycolumn, sym.DIV); }
{Power}           { return token(yytext(), "POWER", yyline, yycolumn, sym.POWER); }
/*{SquareRoot}      { return token(yytext(), "SQRT", yyline, yycolumn, sym.SQRT); }*/

{LeftParen}       { return token(yytext(), "LEFT_PAREN", yyline, yycolumn, sym.LEFT_PAREN); }
{RightParen}      { return token(yytext(), "RIGHT_PAREN", yyline, yycolumn, sym.RIGHT_PAREN); }

{LeftBrace}         { return token(yytext(), "LBRACE", yyline, yycolumn, sym.LBRACE); }
{RightBrace}        { return token(yytext(), "RBRACE", yyline, yycolumn, sym.RBRACE); }

{GT}                { return token(yytext(), "GT", yyline, yycolumn, sym.GT); }
{LT}                { return token(yytext(), "LT", yyline, yycolumn, sym.LT); }
{GE}                { return token(yytext(), "GE", yyline, yycolumn, sym.GE); }
{LE}                { return token(yytext(), "LE", yyline, yycolumn, sym.LE); }
{EQ}                { return token(yytext(), "EQ", yyline, yycolumn, sym.EQ); }
{NE}                { return token(yytext(), "NE", yyline, yycolumn, sym.NE); }

{Assignment}      { return token(yytext(), "ASSIGNMENT", yyline, yycolumn, sym.ASSIGNMENT); }
{Comma}           { return token(yytext(), "COMMA", yyline, yycolumn, sym.COMMA); }
{Semicolon}       { return token(yytext(), "SEMICOLON", yyline, yycolumn, sym.SEMICOLON); }

/* Cualquier otro carácter no reconocido → token de ERROR */
.                 { return token(yytext(), "ERROR", yyline, yycolumn, sym.ERROR); }

/* Al final de archivo, retornamos EOF */
<<EOF>>           { return new Symbol(sym.EOF); }
