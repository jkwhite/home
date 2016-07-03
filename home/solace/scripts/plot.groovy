import groovy.swing.SwingXBuilder;
import java.awt.Color;

def swingx = new SwingXBuilder()


groovy.lang.Closure.metaClass.plot = { color='green' ->
    swingx.graph(plots:[[Color.getField(color).get(null), delegate]])
}
