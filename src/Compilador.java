
import com.formdev.flatlaf.FlatIntelliJLaf;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import compilerTools.ASTNode;
import compilerTools.Directory;
import compilerTools.Functions;
import compilerTools.Grammar;
import compilerTools.Production;
import compilerTools.TextColor;
import compilerTools.Token;
import java.awt.Color;
import java.awt.event.ActionEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import javax.swing.JOptionPane;
import javax.swing.Timer;
import java.util.Collections;
import java.util.Comparator;
import compilerTools.ErrorLSSL;
import java.io.ByteArrayInputStream;
import java.io.Reader;
import javax.swing.table.DefaultTableModel;

/**
 *
 * @author MiStErX
 */
public class Compilador extends javax.swing.JFrame {

    private String title;
    private Directory Directorio;
    private ArrayList<Token> tokens;
    private ArrayList<ErrorLSSL> errors;
    private ArrayList<TextColor> textsColor;
    private Timer timerKeyReleased;
    private ArrayList<Production> identProd;
    private HashMap<String, String> identificadores;
    private boolean codeHasBeenCompiled = false;
    private Object compilerTools;

    /**
     * Creates new form Compilador
     */
    public Compilador() {
        initComponents();
        init();

    }

    private void init() {
        title = "MathLex";
        setLocationRelativeTo(null);
        setTitle(title);
        Directorio = new Directory(this, panel_Codigo, title, ".lex");
        addWindowListener(new WindowAdapter() {// Cuando presiona la "X" de la esquina superior derecha
            @Override
            public void windowClosing(WindowEvent e) {
                Directorio.Exit();
                System.exit(0);
            }
        });
        Functions.setLineNumberOnJTextComponent(panel_Codigo);
        timerKeyReleased = new Timer((int) (1000 * 0.3), (ActionEvent e) -> {
            timerKeyReleased.stop();
            colorAnalysis();
        });
        Functions.insertAsteriskInName(this, panel_Codigo, () -> {
            timerKeyReleased.restart();
        });
        tokens = new ArrayList<>();
        errors = new ArrayList<>();
        textsColor = new ArrayList<>();
        identProd = new ArrayList<>();
        identificadores = new HashMap<>();
        Functions.setAutocompleterJTextComponent(new String[]{"color", "numero", "este", "oeste", "sur", "norte", "pintar"}, panel_Codigo, () -> { //Corregir para proyecto
            timerKeyReleased.restart();
        });
    }

    private void colorAnalysis() {
        /* Limpiar el arreglo de colores */
        textsColor.clear();
        /* Extraer rangos de colores */
        LexerColor lexerColor;
        try {
            File codigo = new File("color.encrypter");
            FileOutputStream output = new FileOutputStream(codigo);
            byte[] bytesText = panel_Codigo.getText().getBytes();
            output.write(bytesText);
            BufferedReader entrada = new BufferedReader(new InputStreamReader(new FileInputStream(codigo), "UTF8"));
            lexerColor = new LexerColor(entrada);
            while (true) {
                TextColor textColor = lexerColor.yylex();
                if (textColor == null) {
                    break;
                }
                textsColor.add(textColor);
            }
        } catch (FileNotFoundException ex) {
            System.out.println("El archivo no pudo ser encontrado... " + ex.getMessage());
        } catch (IOException ex) {
            System.out.println("Error al escribir en el archivo... " + ex.getMessage());
        }
        Functions.colorTextPane(textsColor, panel_Codigo, new Color(40, 40, 40));
    }

    private void getASTAsString(ASTNode node, String indent, StringBuilder sb) {
        if (node == null) {
            return;
        }
        sb.append(indent).append(node.label).append("\n");
        for (ASTNode child : node.children) {
            getASTAsString(child, indent + "  ", sb);
        }
    }

    private void clearFields() {
        Functions.clearDataInTable(tbl_Token);
        panel_Salida.setText("");
        tokens.clear();
        errors.clear();
        identProd.clear();
        identificadores.clear();
        codeHasBeenCompiled = false;
    }

    private void compile() {
        clearFields();
        lexicalAnalysis();
        fieldTableTokens();
        syntacticAnalysis();
        semanticAnalysis();
        printConsole();
        codeHasBeenCompiled = true;
    }

    private void lexicalAnalysis() {
        // Extraer tokens
        tokens.clear();
        Lexer lexer;
        try {
            // 1) Guardar texto en archivo temporal
            File codigo = new File("code.encrypter");
            try (FileOutputStream output = new FileOutputStream(codigo)) {
                byte[] bytesText = panel_Codigo.getText()
                        .getBytes(java.nio.charset.StandardCharsets.UTF_8);
                output.write(bytesText);
            }

            // 2) Abrir reader en UTF-8 y crear el Lexer
            try (BufferedReader entrada = new BufferedReader(
                    new InputStreamReader(new FileInputStream(codigo), java.nio.charset.StandardCharsets.UTF_8))) {
                lexer = new Lexer(entrada);

                // 3) Leer símbolos hasta EOF
                while (true) {
                    java_cup.runtime.Symbol symbol = lexer.next_token();
                    if (symbol == null) {
                        break;
                    }
                    // Aquí “sym” es la clase; “symbol” es la variable
                    if (symbol.sym == sym.EOF) {
                        break;
                    }
                    Token token = (Token) symbol.value;
                    tokens.add(token);
                }
            }
        } catch (FileNotFoundException ex) {
            System.err.println("El archivo no pudo ser encontrado: " + ex.getMessage());
        } catch (IOException ex) {
            System.err.println("Error de E/S con el archivo: " + ex.getMessage());
        }
    }

    private void fieldTableTokens() {
        tokens.forEach(token -> {
            Object[] data = new Object[]{token.getLexicalComp(), token.getLexeme(), "[" + token.getLine() + "," + token.getColumn() + "]"};
            Functions.addRowDataInTable(tbl_Token, data);
        });
    }

    private void syntacticAnalysis() {
        errors.clear(); // Limpia errores anteriores
        try {
            String code = panel_Codigo.getText();
            Reader reader = new java.io.StringReader(code);
            Lexer lexer = new Lexer(reader);

            Parser parser = new Parser(lexer);
            java_cup.runtime.Symbol result = parser.parse();

            errors.addAll(parser.errors);

            // Mostrar errores o éxito
            if (!errors.isEmpty()) {
                StringBuilder sb = new StringBuilder();
                sb.append("Errores sintácticos detectados:\n");
                for (compilerTools.ErrorLSSL err : errors) {
                    sb.append(err.toString()).append("\n");
                }
                panel_Salida.setText(sb.toString());
            } else {
                panel_Salida.setText("Compilación sintáctica exitosa. No se detectaron errores.");

                // Mostrar el árbol de derivación en consola
                ASTNode root = (ASTNode) result.value;
                printAST(root, "");
            }
        } catch (Exception ex) {
            panel_Salida.setText("Error durante el análisis sintáctico: " + ex.getMessage());
        }
    }

    private void semanticAnalysis() {

    }

    private void printAST(ASTNode node, String indent) {
        if (node == null) {
            return;
        }
        System.out.println(indent + node.label);
        for (ASTNode child : node.children) {
            printAST(child, indent + "  ");
        }
    }

    private void printConsole() {
        int sizeErrors = errors.size();
        if (sizeErrors > 0) {
            Functions.sortErrorsByLineAndColumn(errors);
            String strErrors = "\n";
            for (ErrorLSSL error : errors) {
                String strError = String.valueOf(error);
                strErrors += strError + "\n";
            }
            panel_Salida.setText("Compilación Terminada...\n" + strErrors + "\nLa compilación terminó con errores");
        } else {
            panel_Salida.setText("Compilación Terminada...");
        }
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane2 = new javax.swing.JScrollPane();
        jTextArea1 = new javax.swing.JTextArea();
        panel_Principal = new javax.swing.JPanel();
        panel_botones = new javax.swing.JPanel();
        btn_Nuevo = new javax.swing.JButton();
        btn_Abrir = new javax.swing.JButton();
        btn_GuardarC = new javax.swing.JButton();
        btn_Guardar = new javax.swing.JButton();
        panel_botones_exec_comp = new javax.swing.JPanel();
        btn_Compilar = new javax.swing.JButton();
        btn_Ejecutar = new javax.swing.JButton();
        btn_VerArbol = new javax.swing.JButton();
        jScrollPane1 = new javax.swing.JScrollPane();
        panel_Codigo = new javax.swing.JTextPane();
        jScrollPane3 = new javax.swing.JScrollPane();
        panel_Salida = new javax.swing.JTextPane();
        jScrollPane4 = new javax.swing.JScrollPane();
        tbl_Token = new javax.swing.JTable();

        jTextArea1.setColumns(20);
        jTextArea1.setRows(5);
        jScrollPane2.setViewportView(jTextArea1);

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        getContentPane().setLayout(new javax.swing.BoxLayout(getContentPane(), javax.swing.BoxLayout.LINE_AXIS));

        btn_Nuevo.setFont(new java.awt.Font("Consolas", 1, 14)); // NOI18N
        btn_Nuevo.setText("Nuevo");
        btn_Nuevo.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btn_NuevoActionPerformed(evt);
            }
        });

        btn_Abrir.setFont(new java.awt.Font("Consolas", 1, 14)); // NOI18N
        btn_Abrir.setText("Abrir");
        btn_Abrir.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btn_AbrirActionPerformed(evt);
            }
        });

        btn_GuardarC.setFont(new java.awt.Font("Consolas", 1, 14)); // NOI18N
        btn_GuardarC.setText("Guardar Como");
        btn_GuardarC.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btn_GuardarCActionPerformed(evt);
            }
        });

        btn_Guardar.setFont(new java.awt.Font("Consolas", 1, 14)); // NOI18N
        btn_Guardar.setText("Guardar");
        btn_Guardar.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btn_GuardarActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout panel_botonesLayout = new javax.swing.GroupLayout(panel_botones);
        panel_botones.setLayout(panel_botonesLayout);
        panel_botonesLayout.setHorizontalGroup(
            panel_botonesLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(panel_botonesLayout.createSequentialGroup()
                .addGap(9, 9, 9)
                .addComponent(btn_Nuevo)
                .addGap(18, 18, 18)
                .addComponent(btn_Abrir)
                .addGap(18, 18, 18)
                .addComponent(btn_Guardar)
                .addGap(18, 18, 18)
                .addComponent(btn_GuardarC)
                .addContainerGap(9, Short.MAX_VALUE))
        );
        panel_botonesLayout.setVerticalGroup(
            panel_botonesLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, panel_botonesLayout.createSequentialGroup()
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGroup(panel_botonesLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(btn_Nuevo)
                    .addComponent(btn_Abrir)
                    .addComponent(btn_Guardar)
                    .addComponent(btn_GuardarC))
                .addContainerGap())
        );

        btn_Compilar.setFont(new java.awt.Font("Consolas", 1, 14)); // NOI18N
        btn_Compilar.setText("Compilar");
        btn_Compilar.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btn_CompilarActionPerformed(evt);
            }
        });

        btn_Ejecutar.setFont(new java.awt.Font("Consolas", 1, 14)); // NOI18N
        btn_Ejecutar.setText("Ejecutar");
        btn_Ejecutar.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btn_EjecutarActionPerformed(evt);
            }
        });

        btn_VerArbol.setFont(new java.awt.Font("Consolas", 1, 14)); // NOI18N
        btn_VerArbol.setText("Arbol de Derivacion");
        btn_VerArbol.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btn_VerArbolActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout panel_botones_exec_compLayout = new javax.swing.GroupLayout(panel_botones_exec_comp);
        panel_botones_exec_comp.setLayout(panel_botones_exec_compLayout);
        panel_botones_exec_compLayout.setHorizontalGroup(
            panel_botones_exec_compLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(panel_botones_exec_compLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(btn_VerArbol)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(btn_Compilar)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(btn_Ejecutar)
                .addGap(0, 9, Short.MAX_VALUE))
        );
        panel_botones_exec_compLayout.setVerticalGroup(
            panel_botones_exec_compLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, panel_botones_exec_compLayout.createSequentialGroup()
                .addContainerGap(7, Short.MAX_VALUE)
                .addGroup(panel_botones_exec_compLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(btn_Ejecutar)
                    .addComponent(btn_Compilar)
                    .addComponent(btn_VerArbol))
                .addContainerGap())
        );

        panel_Codigo.setFont(new java.awt.Font("Monospaced", 0, 13)); // NOI18N
        jScrollPane1.setViewportView(panel_Codigo);

        panel_Salida.setFont(new java.awt.Font("Monospaced", 0, 13)); // NOI18N
        jScrollPane3.setViewportView(panel_Salida);

        tbl_Token.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null},
                {null, null, null},
                {null, null, null},
                {null, null, null}
            },
            new String [] {
                "Componente Lexico", "Lexema", "[Línea, Columna]"
            }
        ));
        jScrollPane4.setViewportView(tbl_Token);

        javax.swing.GroupLayout panel_PrincipalLayout = new javax.swing.GroupLayout(panel_Principal);
        panel_Principal.setLayout(panel_PrincipalLayout);
        panel_PrincipalLayout.setHorizontalGroup(
            panel_PrincipalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(panel_PrincipalLayout.createSequentialGroup()
                .addGap(12, 12, 12)
                .addGroup(panel_PrincipalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(jScrollPane3)
                    .addGroup(panel_PrincipalLayout.createSequentialGroup()
                        .addComponent(panel_botones, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addGap(147, 147, 147)
                        .addComponent(panel_botones_exec_comp, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(jScrollPane1))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jScrollPane4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap())
        );
        panel_PrincipalLayout.setVerticalGroup(
            panel_PrincipalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(panel_PrincipalLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(panel_PrincipalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addGroup(panel_PrincipalLayout.createSequentialGroup()
                        .addGroup(panel_PrincipalLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(panel_botones_exec_comp, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(panel_botones, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 245, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jScrollPane3, javax.swing.GroupLayout.PREFERRED_SIZE, 136, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(jScrollPane4))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        getContentPane().add(panel_Principal);

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void btn_NuevoActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btn_NuevoActionPerformed
        Directorio.New();
        clearFields();
    }//GEN-LAST:event_btn_NuevoActionPerformed

    private void btn_AbrirActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btn_AbrirActionPerformed
        if (Directorio.Open()) {
            colorAnalysis();
            clearFields();
        }
    }//GEN-LAST:event_btn_AbrirActionPerformed

    private void btn_GuardarActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btn_GuardarActionPerformed
        if (Directorio.Save()) {
            clearFields();
        }
    }//GEN-LAST:event_btn_GuardarActionPerformed

    private void btn_GuardarCActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btn_GuardarCActionPerformed
        if (Directorio.SaveAs()) {
            clearFields();
        }
    }//GEN-LAST:event_btn_GuardarCActionPerformed

    private void btn_CompilarActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btn_CompilarActionPerformed
        if (getTitle().contains("*") || getTitle().equals(title)) {
            if (Directorio.Save()) {
                compile();
            }
        } else {
            compile();
        }
    }//GEN-LAST:event_btn_CompilarActionPerformed

    private void btn_EjecutarActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btn_EjecutarActionPerformed
        btn_Compilar.doClick();
        if (codeHasBeenCompiled) {
            if (!errors.isEmpty()) {
                JOptionPane.showMessageDialog(null, "No se puede ejecutar el código ya que se encontró uno o más errores");
            }
        } else {

        }
    }//GEN-LAST:event_btn_EjecutarActionPerformed

    private void btn_VerArbolActionPerformed(java.awt.event.ActionEvent evt) {
        try {
            String code = panel_Codigo.getText();
            Reader reader = new java.io.StringReader(code);
            Lexer lexer = new Lexer(reader);
            Parser parser = new Parser(lexer);
            java_cup.runtime.Symbol result = parser.parse();

            errors.clear();
            errors.addAll(parser.errors);

            if (!errors.isEmpty()) {
                JOptionPane.showMessageDialog(this, "Corrige los errores sintácticos antes de ver el árbol.");
                return;
            }

            // Aquí va la validación:
            if (!(result.value instanceof ASTNode)) {
                JOptionPane.showMessageDialog(this, "No se pudo generar el árbol de derivación (resultado inesperado).");
                return;
            }
            ASTNode root = (ASTNode) result.value;
            StringBuilder sb = new StringBuilder();
            getASTAsString(root, "", sb);

            VentanaArbol ventana = new VentanaArbol(sb.toString());
            ventana.setVisible(true);
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Error al generar el árbol: " + ex.getMessage());
        }
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(() -> {
            try {
                UIManager.setLookAndFeel(new FlatIntelliJLaf());
            } catch (UnsupportedLookAndFeelException ex) {
                System.out.println("LookAndFeel no soportado: " + ex);
            }
            new Compilador().setVisible(true);
        });
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton btn_Abrir;
    private javax.swing.JButton btn_Compilar;
    private javax.swing.JButton btn_Ejecutar;
    private javax.swing.JButton btn_Guardar;
    private javax.swing.JButton btn_GuardarC;
    private javax.swing.JButton btn_Nuevo;
    private javax.swing.JButton btn_VerArbol;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JScrollPane jScrollPane4;
    private javax.swing.JTextArea jTextArea1;
    private javax.swing.JTextPane panel_Codigo;
    private javax.swing.JPanel panel_Principal;
    private javax.swing.JTextPane panel_Salida;
    private javax.swing.JPanel panel_botones;
    private javax.swing.JPanel panel_botones_exec_comp;
    private javax.swing.JTable tbl_Token;
    // End of variables declaration//GEN-END:variables
}
