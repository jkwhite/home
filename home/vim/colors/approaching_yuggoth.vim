" Vim color file (finding_yuggoth.vim)                                            
" Maintainer:    john white <dhcmrlchtdj@gmail.com>
" Last Change:   20150124

" a gvim space theme with some extra java highlighting.
" the java highlighting depends on claudio fleiner's
" java.vim syntax highlighting at
" http://www.fleiner.com/vim/download.html

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "approaching_yuggoth"

hi Normal        guifg=#d1ffdd guibg=#000000
hi Cursor        guibg=#fffffa guifg=Black
hi CursorLine    guibg=#335577
hi lCursor       guibg=#bababa guifg=Black
hi ModeMsg       gui=bold
hi StatusLine    gui=bold
hi StatusLineNC  gui=bold
hi VertSplit     gui=bold
hi LineNr        guifg=DarkGrey
hi Visual        gui=bold guifg=Grey guibg=fg
hi VisualNOS     gui=underline,bold
hi Directory     guifg=Grey
hi MoreMsg       gui=bold guifg=White
hi NonText       gui=bold guifg=DarkGrey
hi Question      gui=bold guifg=White
hi Search        guibg=#ffff99 guifg=Black
hi IncSearch     gui=bold guifg=Yellow
hi SpecialKey    guifg=White
hi Title         gui=bold guifg=Grey
hi WildMenu      guibg=Yellow guifg=Black
hi Folded        guifg=Grey guibg=#554455
hi FoldColumn    guifg=Grey guibg=#554455
hi DiffText      gui=bold guibg=#442266
hi DiffAdd       guibg=#000055
hi DiffChange    guibg=#220044
hi DiffDelete    gui=bold guifg=#604060 guibg=#302030
hi ErrorMsg      gui=bold guifg=Black
hi WarningMsg    guifg=Black

" general highlighting
hi Constant      gui=bold guifg=#c88030
hi Special       guifg=#a5e4df
hi Ignore        guifg=red
hi Number        guifg=#c88030
hi Type          guifg=#e3ec93
"86e7f9
hi Comment       guifg=#d5b8d6
hi Statement     guifg=#88b1fd
hi Label         gui=bold guifg=#805070
hi Todo          gui=bold guifg=black
hi String        guifg=#a9a9e9
hi Operator      guifg=#a0e0ef
hi Identifier    guifg=#7878ff
hi Pmenu         guibg=#101033 guifg=#999999 gui=bold

hi MatchParen    gui=bold guibg=#000022

" java highlighting
hi javaAnnotation guifg=#ed56cb
hi javaExternal  guifg=#868686
hi javaScopeDecl guifg=#d3a27a
hi javaParen     guifg=#80a0ff
hi javaParen1    guifg=#a0c0ff
hi javaParen2    guifg=#c0e0ff
hi javaFuncDef   guifg=#7080f0
hi javaLangObject guifg=#6080c0
hi javaBraces    guifg=#406090
