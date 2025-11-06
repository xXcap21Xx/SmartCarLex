/* -------------------------------------------------------------------
   LexerColor.flex para coloreado de sintaxis. Basado en tu Lexer.flex,
   pinta comentarios, números, operadores, palabras reservadas, etc.
   Devuelve objetos TextColor en lugar de Symbols de CUP.
   ------------------------------------------------------------------- */

import compilerTools.TextColor
java_import java.awt.Color

%%

%class LexerColor
%unicode
%char
%line
%column

%{
    // Auxiliar para crear TextColor: posición inicial, tamaño y color
    private TextColor textColor(long start, int size, Color color) {
        return new TextColor((int) start, size, color);
    }
%}

/* ====================== SECCIÓN DE MACROS ====================== */

/* Espacios y saltos de línea */
LineTerminator       = \r|\n|\r\n
InputCharacter       = [^\r\n]
WhiteSpace           = {LineTerminator}|[ \t\f]

/* Comentarios multilínea estilo C */
TraditionalComment = "/*" [^*]* ~"*/" | "/*" "*"+ "/"

EndOfLineComment     = "//"{InputCharacter}*{LineTerminator}?
Comment              = {TraditionalComment}|{EndOfLineComment}

/* Identificadores */
Identifier           = [a-zA-Z][a-zA-Z0-9]*

/* Literales numéricas */
IntegerLiteral       = 0|([1-9][0-9]*)
FloatLiteral         = {IntegerLiteral}"."[0-9]+

/* Operadores simbólicos */
Plus                 = "\+"
Minus                = "\-"
Multiply             = "\*"
Divide               = "/"
Power                = "\^"
SquareRoot           = "sqrt"

/* Agrupación */
LeftParen            = "\("
RightParen           = "\)"
LeftBrace           = "\{"
RightBrace          = "\}"

/* Palabras reservadas */
ADD                  = "\+"
SUB                  = "\-"
DIV                  = "/"
MUL                  = "\*"
SIN                  = "SIN"
PI                   = "π"

If                  = "if"
Else                = "else"
For                 = "for"

/* Otros símbolos */
Assignment           = "="
Comma                = ","

%%

/* ====================== SECCIÓN DE REGLAS ====================== */

/* 1) Comentarios (gris claro) */
{Comment}            { return textColor(yychar, yylength(), new Color(146,146,146)); }

/* 2) Espacios y saltos de línea (ignorar) */
{WhiteSpace}+        { /* Ignorar */ }

/* 3) Literales flotantes (verde) */
{FloatLiteral}       { return textColor(yychar, yylength(), new Color(0,128,0)); }

/* 4) Literales enteras (verde) */
{IntegerLiteral}     { return textColor(yychar, yylength(), new Color(0,128,0)); }

/* 5) Palabras reservadas (azul) */
{SquareRoot}         { return textColor(yychar, yylength(), new Color(0,0,255)); }
{SIN}                { return textColor(yychar, yylength(), new Color(0,0,255)); }
{PI}                 { return textColor(yychar, yylength(), new Color(0,0,255)); }
{If}                 { return textColor(yychar, yylength(), new Color(0,0,255)); }
{Else}               { return textColor(yychar, yylength(), new Color(0,0,255)); }
{For}                { return textColor(yychar, yylength(), new Color(0,0,255)); }

/* 6) Operadores simbólicos (rojo) */
{Plus}               { return textColor(yychar, yylength(), new Color(200,0,0)); }
{Minus}              { return textColor(yychar, yylength(), new Color(200,0,0)); }
{Multiply}           { return textColor(yychar, yylength(), new Color(200,0,0)); }
{Divide}             { return textColor(yychar, yylength(), new Color(200,0,0)); }
{Power}              { return textColor(yychar, yylength(), new Color(200,0,0)); }

/* 7) Identificadores (negro) */
{Identifier}         { return textColor(yychar, yylength(), new Color(0,0,0)); }

/* 8) Agrupación (gris oscuro) */
{LeftParen}          { return textColor(yychar, yylength(), new Color(100,100,100)); }
{RightParen}         { return textColor(yychar, yylength(), new Color(100,100,100)); }
{LeftBrace}          { return textColor(yychar, yylength(), new Color(100,100,100)); }
{RightBrace}         { return textColor(yychar, yylength(), new Color(100,100,100)); }

/* 9) Símbolos adicionales (gris oscuro) */
{Assignment}         { return textColor(yychar, yylength(), new Color(100,100,100)); }
{Comma}              { return textColor(yychar, yylength(), new Color(100,100,100)); }

/* 10) Cualquier otro carácter (por ejemplo, símbolos desconocidos): ignorar */
.                    { /* Ignorar */ }
