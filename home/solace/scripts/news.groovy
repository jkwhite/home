import groovy.swing.SwingBuilder;
import java.awt.BorderLayout;
import java.awt.Font;
import java.awt.Dimension;
import javax.swing.*;
import javax.swing.text.*;
import javax.swing.text.html.HTMLDocument;
import javax.swing.text.html.StyleSheet;

class NewsItem {
    def title
    def url
    def description
}

xml = { url='http://rss.slashdot.org/Slashdot/slashdot' ->
    new XmlParser().parse(url)
}

news = { url='http://rss.slashdot.org/Slashdot/slashdot' ->
    def xml = new XmlParser().parse(url)
    def items = xml.item?:xml.channel[0].item
    def ns = []
    items.each { ns << new NewsItem(title:it.title.text(), url:it.link.text(), description:it.description.text()) }
    ns.sequence()
}

$c.renderer.link(NewsItem, new org.excelsi.solace.Renderer() {
        JComponent render(Object ns, String... context) {
            def details = null
            def p = new SwingBuilder().panel() {
                borderLayout()
                vbox(constraints:BorderLayout.WEST) {
                    hbox { label(text:"<html><b><a href='${ns.url}'>${ns.title}</a></b></html>", horizontalAlignment:SwingConstants.LEFT,
                        mouseClicked:{
                            if(details.visible) {
                                details.visible=false
                                details.preferredSize=[0,0]
                            }
                            else {
                                details.visible=true
                                details.preferredSize=[600,200]
                            }
                        }) }
                    hbox { details = label(text:"<html>${ns.description}</html>", visible:false) }
                }
            }
            return p
        }
    })
