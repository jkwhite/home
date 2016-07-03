$c.keybindings['\t'] = {
    def compl = []
    def line = $c.lineToCaret
    def dot = line.lastIndexOf '.'
    def last = '[A-Za-z]'
    //System.err.println("pos: "+$c.getCaretPosition());
    //System.err.println("line: "+line);
    if(dot==-1) {
        // comp from global vars
        if(line.length()>0) last = line
        compl += $s.variables.findAll { it ==~ "${last}.*" }
    }
    else {
        def eval = line.substring(0, dot)
        //System.err.println("eval: "+eval);
        //System.err.println("dot: "+dot);
        //System.err.println("lin: "+line.length());
        if(dot!=line.length()-1) {
            last = line.substring(dot+1, line.length())
        }
        //System.err.println("last: "+last);
        def res = $s.evaluate(eval)
        def resc = res instanceof Class ? res:res.class
        compl += resc.methods.findAll { it.name ==~ "${last}.*" }.collect { it.name+"("+it.parameterTypes.collect { it.simpleName }.join(', ')+")" }
        compl += res.metaClass.metaMethods.findAll { it.name ==~ "${last}.*" }.collect { it.name+"("+it.parameterTypes.collect { it.name.lastIndexOf('.')>=0?it.name.substring(1+it.name.lastIndexOf('.')):it.name }.join(', ')+")" }
        compl.removeAll { it ==~ '[gs]et[A-Z].*' }
        compl += res.properties.findAll { it.key ==~ "${last}.*" }.collect { it.key }
        compl.sort()
    }
    if(compl.size==1) {
        $c.hideSelect()
        $c.append(compl[0].substring(last.length()))
    }
    else {
        $c.select(compl)
    }
}
