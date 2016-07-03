au   BufEnter *   execute ":lcd " . substitute(expand("%:p:h"), "\\s", "\\\\ ", "g")
