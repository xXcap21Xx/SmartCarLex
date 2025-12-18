/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author MiStErX
 */
public class Simbolo {

    String nombre;
    String tipo;
    String valor;
    int linea;
    int columna;

    public Simbolo(String nombre, String tipo, String valor, int linea, int columna) {
        this.nombre = nombre;
        this.tipo = tipo;
        this.valor = valor;
        this.linea = linea;
        this.columna = columna;
    }

    // Getters para la tabla
    public Object[] toArray() {
        return new Object[]{nombre, tipo, valor, linea, columna};
    }
}
