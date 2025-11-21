import compilerTools.TextColor;
import java.awt.Color;

%%

%class LexerColor
%unicode
%char
%line
%column

%{
    private TextColor textColor(long start, int size, Color color) {
        return new TextColor((int) start, size, color);
    }
%}

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace     = {LineTerminator} | [ \t\f]
Comment        = "//" {InputCharacter}* {LineTerminator}? | "/*" [^*]* ~"*/"
Identifier     = [a-zA-Z_] [a-zA-Z0-9_]*
NumberLiteral  = [0-9]+ (\.[0-9]+)?
StringLiteral  = \"([^\\\"]|\\.)*\"

%%

/* Comentarios (Gris Claro) */
{Comment} { return textColor(yychar, yylength(), new Color(146, 146, 146)); }

/* Strings (Naranja) */
{StringLiteral} { return textColor(yychar, yylength(), new Color(255, 128, 0)); }

/* Números (Verde) */
{NumberLiteral} { return textColor(yychar, yylength(), new Color(0, 128, 0)); }

/* --- PALABRAS RESERVADAS (Azul) --- */
/* Estructura y Tipos */
"program" | "inicio" | "end" | "metodo" | "rutina" | "entrada" | "salida" | "regresa" |
"var" | "const" | "set" | "num" | "bool" | "str" | "true" | "false" |

/* Control */
"cuando" | "sino" | "mientras" | "loop" | "salir" | "sigue" |

/* Vehículo */
"move" | "turn" | "stop" | "wait" | "accelerate" | "decelerate" | "reverse" | "brake" |

/* Sensores */
"sensor" | "gps" | "speed" | "distance" | "obstacle" |

/* Comunicación */
"broadcast" | "receive" | "message" | "event" | "on" | "vehicle_id" |

/* Navegación */
"route" | "waypoint" | "goto" | "map" | "navigate" | "destination" 

{ return textColor(yychar, yylength(), new Color(0, 0, 255)); }

/* --- OPERADORES (Rojo) --- */
"==" | "!=" | "<=" | ">=" | "&&" | "||" |
"+" | "-" | "*" | "/" | "%" | "=" | "<" | ">" | "!" 
{ return textColor(yychar, yylength(), new Color(200, 0, 0)); }

/* --- PUNTUACIÓN (Gris Oscuro) --- */
";" | "," | "(" | ")" | "{" | "}" | "[" | "]" 
{ return textColor(yychar, yylength(), new Color(100, 100, 100)); }

{Identifier} { return textColor(yychar, yylength(), new Color(0, 0, 0)); }
{WhiteSpace} { /* Ignorar */ }
. { /* Ignorar */ }