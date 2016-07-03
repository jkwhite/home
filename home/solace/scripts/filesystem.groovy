import javax.swing.*;
import java.awt.Image;
import java.io.File;

cwd = System.getProperty("user.home")

ls = { f='.*' ->
    Arrays.asList(new File(cwd).listFiles())
        .findAll({ it.getName() ==~ /[^\.].*/ })
        .findAll({ it.getName() ==~ f })
}

ll = { f='.*' ->
    ls(f).table(1)
}

cd = { dir ->
    ncwd = new File("${cwd}/${dir}").getAbsoluteFile()
    if(ncwd.exists()) {
        cwd = ncwd.toString();
    }
    else if(!ncwd.isDirectory()) {
        println "'${dir}' is not a directory"
    }
    else {
        println "no such directory '${dir}'"
    }
}

$c.renderer.link(File, new org.excelsi.solace.Renderer() {
        JComponent render(Object file, String... context) {
            if(file.name ==~ /.*\.(jpg|png)/) {
                def i = new ImageIcon(file.toString())
                if(! file.name.endsWith("gif")) {
                    // gifs don't like being scaled for some reason
                    if(i.iconWidth>50 || i.iconHeight>50) {
                        int scalef = Math.max(1, (Math.max(i.iconWidth, i.iconHeight) / 50f));
                        i.image = i.image.getScaledInstance((int) i.iconWidth/scalef, (int) i.iconHeight/scalef, Image.SCALE_SMOOTH)
                    }
                }
                return new JLabel(i).label(file.name);
            }
            else {
                return new JLabel(file.name)
            }
        }
    })
