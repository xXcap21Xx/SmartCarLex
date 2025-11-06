
import java.util.logging.Level;
import java.util.logging.Logger;
import jflex.exceptions.SilentExit;

/**
 *
 * @author MiStErX
 */
public class ExecuteJFlex {
    public static void main(String[] args) {
        String lexerFile = System.getProperty("user.dir")+"/src/Lexer.flex",
                lexerColor = System.getProperty("user.dir")+"/src/LexerColor.flex";
        
        try {
            jflex.Main.generate(new String[]{lexerFile, lexerColor});
        } catch (SilentExit ex) {
            Logger.getLogger(ExecuteJFlex.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
