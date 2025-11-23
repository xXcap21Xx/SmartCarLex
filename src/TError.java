/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author MiStErX
 */
public class TError {
    public int lexema, linea, columna;
    public String tipo, descripcion;

    public TError(int linea, int columna, String descripcion) {
        this.linea = linea;
        this.columna = columna;
        this.descripcion = descripcion;
    }

    @Override
    public String toString() {
        return "[" + linea + ":" + columna + "] " + descripcion;
    }
}
