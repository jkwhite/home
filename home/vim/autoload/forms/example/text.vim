
function! forms#example#text#Make()
  let text = forms#newText({'textlines': [
                                      \ "Now is the time", 
                                      \ "to speak of many things.", 
                                      \ "Of cabages and kings.", 
                                      \ ]})
  let b = forms#newBorder({ 'body': text })
  let bg = forms#newBackground({ 'body': b} )

  let form = forms#newForm({'body': bg })
  call form.run()
endfunction

