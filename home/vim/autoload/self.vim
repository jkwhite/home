" ============================================================================
" self.vim
"
" File:          self.vim
" Summary:       Vim Self Object Prototype System
" Author:        Richard Emberson <richard.n.embersonATgmailDOTcom>
" Last Modified: 06/30/2012
" Version:       2.0
" Modifications:
"  1.0 : initial public release.
"  2.0 : corrections for the forms library
"
" Tested on vim 7.3 on Linux
"
" ============================================================================
" Intro:
" Vim Self Object Prototype System allows developer to create
"   object-base scripts (inspired after the David Ungar's Self language).
"
" This code to be used by script developers, not for direct use by
"   end users (by itself, it does nothing).
"
" When Vim version 7.0 with dictionary variables and function references
"   came out, I created this object prototype support script. At that time
"   I was planning to write a text-base windowing system on top of Vim which
"   would allow script to create such things as forms. During script
"   installation having per-script driven forms allowing for the tailoring
"   of the script environment might have been a good thing.
"
" Anyway, time pasted and I moved onto other projects without really
"   finishing this script. Then I wanted to create a Scala language
"   comment generation script much like the jcommenter.Vim script for
"   Java. My first cut, version 1.0, was all imperative: enumerations for
"   the different entity types (class, object,
"   method, etc.); with functions for different behaviors and
"   switch-case statements (i.e., if-elseif-endif) using the enumeration
"   to determine which block of Vim script to execute. This worked
"   but each entity's behavior was scattered throughout the script file.
"
" I then thought to dust off my old object system and re-casting my
"   Scala comment generator using it. While the code size is the same,
"   now behavior is near the data (or in an object's prototype chain).
"
" So, here is the code. Along with this file there are some simple usage
"   example files also in the download. None of the examples, though, are
"   as complex as what is done in the scalacommenter.vim script.
"
" Later, I wanted to enhance Envim to allow one to enter refactoring options.
"   This required some sort of forms capability. Hence, I built Forms
"   a Vim library, but, along the way, discovered some bugs in the self code.
"   With this release, I hope they have all been fixed.
"
" ============================================================================
" Caveats:
" Without deeper native VimScript support for object prototypes, I suspect
"   that there is a performance penalty when using objects rather than
"   imperative functions and switch-case statements.
" Method lookup is static, a child object knows its parent (prototype)
"   object's method at its creation. Post-creation if the parent adds
"   a new method, the child can not access it.
"   Method dispatch does not dynamically walk up the parent chain attempting
"   to find a given method, if the child does not have the method (if
"   the child, which is a dictionary, does not have the method as a key,
"   then an error occurs - no chance to walk up the parent hierarchy.
" When an object has a type name (the '_type' key) that ends with the string
"   'Prototype', then children of the object have the object as their parent
"   (their prototype) and the child's type name will be parent's type
"   name with the 'Prototype' part removed.
"   On the other hand, when an object does not have the string
"   'Prototype' in its type name, then children of the object have
"   the object's parent as their parent and have the same type name as
"   the object. If this is not done, then when the child objects call
"   a method a recursion error occurs. The Vim "call()" mechanism is
"   not powerful enough to support passing the object, 'self', as well
"   as chaining up the prototype hierarchy with self._prototype,
"   self._prototype._prototype, self._prototype._prototype._prototype
"   and so on. Bram Moolenaar if you want to discuss this, contact me.
" All of the object methods are anonymous functions that make debugging
"   really hard; for a stack trace all you get are a bunch of numbers
"   as function names. Now, if you print out the keys of an object you
"   get both the function name and its number. Its too bad that stack
"   trace print the function's number rather than the function's name.
" Objects based upon the self prototype are separated into two types: those
"   that serve as prototypes for an application's objects and those that
"   are simply part of the prototype hierarchy. These are called out
"   separately because after an application is done, one might wish to
"   free up some memory and delete the objects associated with the
"   application, but one does not want to delete the base prototype
"   objects since they might be used again - for instance, if the
"   application is re-invoked. To that end, all objects have an '_id'
"   attribute, but for objects in a prototype hierarchy, the _id's
"   are negative number while for "application" objects, the _id's
"   are positive. Also, there are two different object managers, one
"   for each type of object.
"
" ============================================================================
" Configuration Options:
"   These help control the behavior of Self.vim
"   Remember, if you change these and then upgrade to a later version,
"   your changes will be lost.
" ============================================================================

" Define these just to make the code a little more readable
" One could simply use 0 and 1, but these, it think, are clear to
" see what is happening (but, maybe not).
" Existance check is to allow reloading of file.
if ! exists("g:self#IS_FALSE")
  let g:self#IS_FALSE = 0
  lockvar g:self#IS_FALSE
endif
if ! exists("g:self#IS_TRUE")
  let g:self#IS_TRUE = 1
  lockvar g:self#IS_TRUE
endif

" If set to true, then when re-sourcing this file during a vim session
"   static/global objects may be initialized again before use.
if ! exists("g:self#IN_DEVELOPMENT_MODE")
  let g:self#IN_DEVELOPMENT_MODE = g:self#IS_TRUE
endif


" ============================================================================
" Description:
"
" Base Object Prototype for creating a prototype-base object inheritance
"   hierarchy.
"
" This is not a class-base Object-Orient system, rather it is
"   prototype-base. The Self language was, I believe, the first such
"   language. One of the more popular language today is prototype-base
"   (Do you know which language I am referring to?).
"
" With prototype-base OO language, child objects are created by making
"   a copy of another, the parent or prototype, object. Additional
"   instance variables and methods can be added to the child object. Also,
"   methods of the child's parent (again, its prototype) can also
"   be redefined.
"
" By convention, the names of public methods and values should not start
"   with an underscore. Private methods and values have names starting
"   with a single leading '_'. Methods and values with names starting
"   with multiple '_'s are protected.
"   Public and protected methods and values are copied into child
"   objects during creation. Private methods and values are not copied
"   during object creation.
"
" ============================================================================
" Installation:
"
" 1. If needed, edit the configuration section. Any configuration options
"   are commented, so I won't explain the options here.
"
" 2. Put something like this in your .vimrc file:
"
"      source $VIM/macros/self.vim
"      source $VIM/macros/some_scrip.vim
"
"   or wherever you put your Vim scripts.
"   Here, some_scrip.vim a script that requires the self.vim script
"  
" ============================================================================
" Usage:
"
" For the end-user there is no particular usage information.
"
" ============================================================================
" Comments:
"
"   Send any comments or bugreports to:
"       Richard Emberson <richard.n.embersonATgmailDOTcom>
"
" ============================================================================
" THE SCRIPT
" ============================================================================

" Load Once:
if &cp || ( exists("g:loaded_self") && ! g:self#IN_DEVELOPMENT_MODE )
  finish
endif
let g:loaded_self = 'v2.0'
let s:keepcpo = &cpo
set cpo&vim

" ++++++++++++++++++++++++++++++++++++++++++++
" Reload :
" ++++++++++++++++++++++++++++++++++++++++++++

" ------------------------------------------------------------
" self#reload:
"  With Vim autoloading, this function can be used to force a
"    reloading of functions that were autoloaded.
"  This function is only available in development mode, i.e.,
"    g:self#IN_DEVELOPMENT_MODE == self#IS_TRUE
"  To make reloading of autoloaded functions simple, one might
"    want to define a mapping. Lets say your prefix is 'joesvimcode#'.
"    Then the mapping might be:
"      map <Leader>r :call self#reload('joesvimcode#')
"    or if there is a sub-code base to be reloaed
"      map <Leader>r :call self#reload('joesvimcode#somesubcode#')
"  To reload the self.vim functions use:
"    :call self#reload('self#')
"
"  Note that calling self#reload will delete/unlet all objects, so
"    if you are working on a library that uses the self library,
"    you really ought to reload that liberary at the same time.
"
"  parameters:
"    prefix : The autoload function prefix to match function
"              names against. For instance, to force reload of
"              self functions, the prefix should be 'self#'.
" ------------------------------------------------------------
if !exists("*self#reload")
  if g:self#IN_DEVELOPMENT_MODE
    function self#reload(prefix)
      call self#load_function_names()
      if exists("g:self_function_names")
        let fnlist = split(g:self_function_names, '\n')
        for fn in fnlist
          if fn =~ a:prefix
            let n = strpart(fn, 9)
            let i = stridx(n, '(')
            let n = strpart(n, 0, i)
            let FR = function(n)
            try
              delfunction FR
              " echo "delete " .n
            catch /.*/
              " can not delete current function
            endtry
          endif
        endfor
        unlet g:self_function_names
      endif
    endfunction
  endif
endif

" ------------------------------------------------------------
" self#load_function_names:
"  Load all function names into g:self_function_names
"  parameters: None
" ------------------------------------------------------------
function! self#load_function_names()
    execute "redir => g:self_function_names"
    silent function
    execute "redir END"
endfunction


" Utils :
" ============================================================================
" Public functions
" ============================================================================

" ++++++++++++++++++++++++++++++++++++++++++++
" Print a dictionary item to standard output
" ++++++++++++++++++++++++++++++++++++++++++++

" ++++++++++++++++++++++++++++++++++++++++++++
" Vim type enumerations.
" ++++++++++++++++++++++++++++++++++++++++++++
" Existance check is to allow reloading of file.
if ! exists("g:self#NUMBER_TYPE")
  let g:self#NUMBER_TYPE     = type(0)
  lockvar g:self#NUMBER_TYPE
endif
if ! exists("g:self#STRING_TYPE")
  let g:self#STRING_TYPE     = type("")
  lockvar g:self#STRING_TYPE
endif
if ! exists("g:self#FUNCREF_TYPE")
  let g:self#FUNCREF_TYPE    = type(function("tr"))
  lockvar g:self#FUNCREF_TYPE
endif
if ! exists("g:self#LIST_TYPE")
  let g:self#LIST_TYPE       = type([])
  lockvar g:self#LIST_TYPE
endif
if ! exists("g:self#DICTIONARY_TYPE")
  let g:self#DICTIONARY_TYPE = type({})
  lockvar g:self#DICTIONARY_TYPE
endif
if ! exists("g:self#FLOAT_TYPE")
  let g:self#FLOAT_TYPE     = type(0.0)
  lockvar g:self#FLOAT_TYPE
endif

function! self#printDict(item)
  for key in keys(a:item)
   echo key . ': ' . string(a:item[key])
  endfor
endfunction

function! CaptureFunDef(fname)
  execute "redir => g:fundef"
  execute "function " . a:fname
  execute "redir END"
endfunction

function! GetFunDef(fname)
  silent call CaptureFunDef(a:fname)
  return string(g:fundef)
endfunction

" ++++++++++++++++++++++++++++++++++++++++++++
" g: varname  The variable is global
" s: varname  The variable is local to the current script file
" w: varname  The variable is local to the current editor window
" t: varname  The variable is local to the current editor tab
" b: varname  The variable is local to the current editor buffer
" l: varname  The variable is local to the current function
" a: varname  The variable is a parameter of the current function
" v: varname  The variable is one that Vim predefines
" ++++++++++++++++++++++++++++++++++++++++++++
function! s:gettype(type)
  if exists('s:' . a:type)
    return 's:' . a:type
  elseif exists('g:' . a:type)
    return 'g:' . a:type
  elseif exists('w:' . a:type)
    return 'w:' . a:type
  elseif exists('t:' . a:type)
    return 't:' . a:type
  elseif exists('b:' . a:type)
    return 'b:' . a:type
  else
    return a:type
  endif
endfunction


" ++++++++++++++++++++++++++++++++++++++++++++
" Self Logging :
" ++++++++++++++++++++++++++++++++++++++++++++
if ! exists("g:self_log_file")
  let g:self_log_file = "SELF_LOG"
endif
if ! exists("g:self_do_log")
  let g:self_do_log = g:self#IS_FALSE
endif

function! self#log(msg)
  if g:self_do_log
    execute "redir >> " . g:self_log_file
    silent echo a:msg
    execute "redir END"
  endif
endfunction



" Prototype and Object Managers:

if ! exists("g:self_can_delete_prototypes")
  let g:self_can_delete_prototypes = g:self#IS_FALSE
endif

" Clear all objects (application and prototype)
if g:self#IN_DEVELOPMENT_MODE
  if exists("g:self_PM")
    unlet g:self_PM
  endif
  if exists("g:self_OM")
    unlet g:self_OM
  endif
endif

" Prototype Manager:
function! self#PrototypeManager()
  if !exists("g:self_PM")
    let g:self_PM = { '_id': 0, '_prototypeDB': {} }

    " All id's are negative
    function g:self_PM.nextId() dict
      let g:self_PM._id  = g:self_PM._id - 1
      let l:id = g:self_PM._id
      return l:id
    endfunction

    function g:self_PM.store(prototype) dict
      let l:id = self.nextId()
      let a:prototype._id = l:id
      let self._prototypeDB[l:id] = a:prototype
    endfunction

    function g:self_PM.hasId(id) dict
      return has_key(self._prototypeDB, a:id)
    endfunction

    function g:self_PM.lookup(id) dict
      if has_key(self._prototypeDB, a:id)
        return self._prototypeDB[a:id]
      else
        throw "Prototype does not exist with id: " . a:id
      endif
    endfunction

    function g:self_PM.remove(prototype) dict
      if has_key(a:prototype, '_id')
        call self.removeId(a:prototype._id)
        unlet a:prototype._id
      endif
    endfunction

    function g:self_PM.removeId(id) dict
      if has_key(self._prototypeDB, a:id)
        unlet self._prototypeDB[a:id]
      endif
    endfunction

    function g:self_PM.removeAll() dict
      for key in keys(self._prototypeDB)
        call self.removeId(key)
      endfor
    endfunction

  endif
  return g:self_PM
endfunction

function! self#IsPrototype(obj)
  if type(a:obj) == g:self#DICTIONARY_TYPE
    if has_key(a:obj, '_id')
      return self#PrototypeManager().hasId(a:obj._id)
    else
      return 0
    endif
  else
    return 0
  endif
endfunction


" Object Manager:
function! self#ObjectManager()
  if !exists("g:self_OM")
    let g:self_OM = { '_id': 0, '_objectDB': {} }

    " All id's are positive
    function g:self_OM.nextId() dict
      let g:self_OM._id  = g:self_OM._id + 1
      let l:id = g:self_OM._id
      return l:id
    endfunction

    function g:self_OM.store(prototype) dict
      let a:prototype._id = self.nextId()
      let self._objectDB[a:prototype._id] = a:prototype
    endfunction

    function g:self_OM.hasId(id) dict
      return has_key(self._objectDB, a:id)
    endfunction

    function g:self_OM.lookup(id) dict
      if has_key(self._objectDB, a:id)
        return self._objectDB[a:id]
      else
        throw "Object does not exist with id: " . a:id
      endif
    endfunction

    function g:self_OM.remove(prototype) dict
      if has_key(a:prototype, '_id')
        call self.removeId(a:prototype._id)
        unlet a:prototype._id
      endif
    endfunction

    function g:self_OM.removeId(id) dict
      if has_key(self._objectDB, a:id)
        unlet self._objectDB[a:id]
      endif
    endfunction

    function g:self_OM.removeAll() dict
      for key in keys(self._objectDB)
        call self.removeId(key)
      endfor
    endfunction

  endif
  return g:self_OM
endfunction

function! self#IsObject(obj)
  if type(a:obj) == g:self#DICTIONARY_TYPE
    if has_key(a:obj, '_id')
      return self#ObjectManager().hasId(a:obj._id)
    else
      return 0
    endif
  else
    return 0
  endif
endfunction


" ObjectPrototype Support: /*{{{*/
function! self#InChainTypeClone(...) dict
  call self#log('self#InChainTypeClone calling _cloneType TOP')
  return exists('a:1') ?  g:self_ObjectPrototype._cloneType(self, a:1)
                  \ : g:self_ObjectPrototype._cloneType(self)
endfunction

function! self#NotInChainTypeClone(...) dict
  call self#log('self#NotInChainTypeClone calling _cloneObject TOP')
  return exists('a:1') ? g:self_ObjectPrototype._cloneObject(a:1)
                  \ : g:self_ObjectPrototype._cloneObject(self)
endfunction

function! self#TypeDelete(...) dict
call self#log('self#TypeDelete: TOP')
  if exists('a:1')
call self#log('self#TypeDelete: a:1')
    if self#IsObject(a:1) || self#IsPrototype(a:1)
call self#log('self#TypeDelete: Object or Type')
      if a:1._type == 'self_ObjectPrototype'
call self#log('self#TypeDelete: self_ObjectPrototype')
        if self#IsObject(self)
call self#log('self#TypeDelete: Object')
          call g:self_ObjectPrototype._deleteObject(self)
        elseif self#IsPrototype(self)
call self#log('self#TypeDelete: Type')
          call g:self_ObjectPrototype._deleteType(self)
        else
          throw 'self#TypeDelete: self neither Object nor Type'
        endif
      else
call self#log('self#TypeDelete: not self_ObjectPrototype')
        call call(a:1._prototype.delete, [a:1._prototype], self)
      endif
    else
      throw 'self#TypeDelete: a:1 neither Object nor Type'
    endif
  else
call self#log('self#TypeDelete: no a:1')
    if self#IsObject(self) || self#IsPrototype(self)
call self#log('self#TypeDelete: Object or Type')
      if self._type == 'self_ObjectPrototype'
call self#log('self#TypeDelete: self_ObjectPrototype')
        call g:self_ObjectPrototype._deleteType(self)
      else
call self#log('self#TypeDelete: not self_ObjectPrototype')
        call call(self._prototype.delete, [self._prototype], self)
      endif
    else
      throw 'self#TypeDelete: self neither Object nor Type'
    endif
  endif
endfunction

function! self#ObjectDelete(...) dict
call self#log('self#ObjectDelete: TOP')
  if exists('a:1')
call self#log('self#ObjectDelete: a:1')
    if self#IsObject(a:1)
call self#log('self#ObjectDelete: Object')
      call call(a:1._prototype.delete, [a:1._prototype], self)
    else
      throw 'self#ObjectDelete: a:1 neither Object nor Type'
    endif
  else
call self#log('self#ObjectDelete: no a:1')
    if self#IsObject(self)
call self#log('self#ObjectDelete: Object')
      call call(self._prototype.delete, [self._prototype], self)
    else
      throw 'self#ObjectDelete: self neither Object nor Type'
    endif
  endif
endfunction



" ObjectPrototype:
" ++++++++++++++++++++++++++++++++++++++++++++
" SELF.VIM self_ObjectPrototype
" ++++++++++++++++++++++++++++++++++++++++++++
function! self#LoadObjectPrototype()
  if g:self#IN_DEVELOPMENT_MODE
    if exists("g:self_ObjectPrototype")
      unlet g:self_ObjectPrototype
    endif
  endif
  if !exists("g:self_ObjectPrototype")
    "-----------------------------------------------
    " private variables
    "-----------------------------------------------
    let g:self_ObjectPrototype = { '_type': 'self_ObjectPrototype' , '_prototype': '' }
    call self#PrototypeManager().store(g:self_ObjectPrototype)

    "-----------------------------------------------
    " public methods
    "-----------------------------------------------
    function! g:self_ObjectPrototype.init(attrs) dict
" call self#log("self_ObjectPrototype.init TOP")
      if type(a:attrs) != g:self#DICTIONARY_TYPE
        throw "g:self_ObjectPrototype.init attrs type not Dictionary"
      endif
      for name in keys(a:attrs)
        if exists("self.__" . name)
          unlet self['__' . name]
          let self['__' . name] = a:attrs[name]
        elseif name == 'tag'
          let self['__' . name] = a:attrs[name]
        endif
      endfor
" call self#log("self_ObjectPrototype.init BOTTOM")
      return self
    endfunction

    function g:self_ObjectPrototype.getType() dict
      return g:self_ObjectPrototype._getType(self)
    endfunction

    function g:self_ObjectPrototype.isKindOf(kind) dict
      if self.getType() == a:kind
        return g:self#IS_TRUE
      else
        let parent = self._prototype
        while type(parent) == g:self#DICTIONARY_TYPE
          if parent.getType() == a:kind
            return g:self#IS_TRUE
          endif
          if type(parent._prototype) == g:self#DICTIONARY_TYPE
            let parent = parent._prototype
          else
            break
          endif
        endwhile
        return g:self#IS_FALSE
      endif
    endfunction

    function g:self_ObjectPrototype.getPrototype() dict
      return g:self_ObjectPrototype._getPrototype(self)
    endfunction

    function g:self_ObjectPrototype.instanceOf(prototype) dict
      let type = a:prototype._type
      let parent = self._prototype
      while type(parent) == g:self#DICTIONARY_TYPE
        if parent._type == type
          return 1
        endif
        if type(parent._prototype) == g:self#DICTIONARY_TYPE
          let parent = parent._prototype
        else
          break
        endif
      endwhile
      return 0
    endfunction

    function g:self_ObjectPrototype.equals(obj) dict
      if type(a:obj) == g:self#DICTIONARY_TYPE
        if has_key(a:obj, '_id') && has_key(self, '_id')
          return a:obj._id == self._id
        else
          return g:self#IS_FALSE
        endif
      else
        return g:self#IS_FALSE
      endif
    endfunction

    function g:self_ObjectPrototype.super() dict
      throw "self_ObjectPrototype has no super prototype"
    endfunction

    "-----------------------------------------------
    " reserved methods
    "-----------------------------------------------

    function g:self_ObjectPrototype.clone(...) dict
call self#log("clone TOP")
      if exists("a:1")
call self#log("clone a:1=".a:1)
        return g:self_ObjectPrototype._cloneType(self, a:1)
      else
        return g:self_ObjectPrototype._cloneObject(self)
      endif
    endfunction

    " If a:1 exits, it is the object requesting deletion
    " If it does not exist, then its self_ObjectPrototype requesting deletion
    function g:self_ObjectPrototype.delete(...) dict
call self#log("delete TOP")
      if self#IsObject(self)
        call g:self_ObjectPrototype._deleteObject(self)
      elseif self#IsPrototype(self)
        call g:self_ObjectPrototype._deleteType(self)
      else
        throw 'self_ObjectPrototype.delete: self neither Object nor Type'
      endif
    endfunction


    "-----------------------------------------------
    " private methods
    "-----------------------------------------------

    function g:self_ObjectPrototype._getType(prototype) dict
      return a:prototype._type
    endfunction

    function g:self_ObjectPrototype._getPrototype(prototype) dict
      return a:prototype._prototype
    endfunction

    function g:self_ObjectPrototype._cloneType(prototype, ...) dict
call self#log("_cloneType TOP")
call self#log("_cloneType prototype._id=" . a:prototype._id)
call self#log("_cloneType self#PrototypeManager=" . self#PrototypeManager().hasId(a:prototype._id))
      if exists("a:1")
        let l:type = a:1
        let l:inchain = g:self#IS_TRUE
      else
        let l:type = a:prototype._type
        let l:inchain = g:self#IS_FALSE
      endif
call self#log("_cloneType l:type=" . l:type)
call self#log("_cloneType inchain=" . l:inchain)
      let l:o = {}
      for key in keys(a:prototype)
        if key == "_prototype"
          " setting the _prototype
          let l:o[key] = a:prototype

        elseif key == "_type"
          " setting the _type
          let l:o[key] = l:type

        elseif key[0] == '_' && key[1] != '_'
          " Private methods are not copied

        elseif key == "super"
          if l:inchain
            let l:fd =        "function! l:o.super() dict\n"
            let l:fd = l:fd .   "return self#PrototypeManager().lookup(" . a:prototype._id . ")\n"
            let l:fd = l:fd . "endfunction"
            execute l:fd
          else
            let l:fd =        "function! l:o.super() dict\n"
            let l:fd = l:fd .   "let l:p = self#PrototypeManager().lookup(" . a:prototype._id . ")\n"
            let l:fd = l:fd .   "return self#PrototypeManager().lookup(l:p._prototype._id)\n"
            let l:fd = l:fd . "endfunction"
            execute l:fd
          endif

        elseif key == "clone"
          if l:inchain
            let l:o.clone = function("self#InChainTypeClone")

          else
            let l:o.clone = function("self#NotInChainTypeClone")

          endif


        elseif key == "delete"
call self#log("_cloneType making delete")
            let l:o.delete = function("self#TypeDelete")

        else
          if type(a:prototype[key]) == g:self#FUNCREF_TYPE
            " Do NOT call this Object's direct Prototype, rather call its
            " Prototype's Prototype.
            let l:fd =        "function! l:o." . key . "(...) dict\n"
            let l:fd = l:fd .   "let l:o = self#PrototypeManager().lookup(" . a:prototype._id . ")\n"
            let l:fd = l:fd .   "return call(l:o." . key . ", a:000, self)\n"
            let l:fd = l:fd . "endfunction"
            execute l:fd

          elseif type(a:prototype[key]) == g:self#LIST_TYPE
            let l:o[key] = deepcopy(a:prototype[key])

          elseif type(a:prototype[key]) == g:self#DICTIONARY_TYPE
            let l:o[key] = deepcopy(a:prototype[key])

          else
            let l:o[key] = a:prototype[key]
          endif
        endif
      endfor

      if l:inchain
        call self#PrototypeManager().store(l:o)
      else
        call self#ObjectManager().store(l:o)
      endif

" call self#log("_cloneType " . l:o._type . "  " . string(l:o))
call self#log("_cloneType BOTTOM type=" . l:o._type)
call self#log("_cloneType BOTTOM id=" . l:o._id)
call self#log("_cloneType BOTTOM parent._type=" . l:o._prototype._type)
call self#log("_cloneType BOTTOM parent._id=" . l:o._prototype._id)
call self#log("_cloneType BOTTOM super._type=" . l:o.super()._type)
call self#log("_cloneType BOTTOM super._id=" . l:o.super()._id)

      return l:o
    endfunction



    function g:self_ObjectPrototype._cloneObject(prototype) dict
call self#log("_cloneObject TOP")
call self#log("_cloneObject prototype._id=" . a:prototype._id)
call self#log("_cloneObject ObjectManager=" . self#ObjectManager().hasId(a:prototype._id))

      let l:useid = g:self#IS_FALSE
      let l:usetype = g:self#IS_TRUE

      let l:pt1 = a:prototype._type
      if type(a:prototype._prototype) == g:self#DICTIONARY_TYPE
        let l:pt2 = a:prototype._prototype._type
        if l:pt1 != l:pt2
          let l:usetype = g:self#IS_TRUE
        else
          if type(a:prototype._prototype._prototype) == g:self#DICTIONARY_TYPE
            let l:pt3 = a:prototype._prototype._prototype._type
            if l:pt2 != l:pt3
              " use self._prototype
              let l:usetype = g:self#IS_FALSE
            else
              let l:useid = g:self#IS_TRUE
            endif
          else
            " use self._prototype
            let l:usetype = g:self#IS_FALSE
          endif
        endif
      else
        let l:usetype = g:self#IS_TRUE
      endif

      let l:o = {}

      for key in keys(a:prototype)
call self#log("_cloneObject key=".key)
        if key == "_prototype"
          " setting the _prototype
          let l:o[key] = a:prototype

        elseif key == "_type"
          " setting the _type
          let l:o[key] = a:prototype._type

        elseif key[0] == '_' && key[1] != '_'
          " Private methods are not copied

        elseif key == "super"
          if l:useid
            let l:fd =        "function! l:o.super() dict\n"
            let l:fd = l:fd .   "return self#ObjectManager().lookup(" . a:prototype._id . ")\n"
            let l:fd = l:fd . "endfunction"
            execute l:fd

          elseif l:usetype
            let l:fd =        "function! l:o.super() dict\n"
            let l:fd = l:fd .   "return " . s:gettype(l:pt1) . "\n"
            let l:fd = l:fd . "endfunction"
            execute l:fd

          else
            let l:fd =        "function! l:o.super() dict\n"
            let l:fd = l:fd .   "return self._prototype" . "\n"
            let l:fd = l:fd . "endfunction"
            execute l:fd
          endif

        elseif key == "clone"
            let l:fd =        "function! l:o.clone(...) dict\n"
            let l:fd = l:fd .   "call self#log('clone calling clone(self)TOP')\n"
            let l:fd = l:fd .   "let l:o = self#ObjectManager().lookup(" . a:prototype._id . ")\n"
            let l:fd = l:fd .   "if exists('a:1')\n"
            let l:fd = l:fd .     "return l:o.clone(a:1)\n"
            let l:fd = l:fd .   "else\n"
            let l:fd = l:fd .     "return l:o.clone(self)\n"
            let l:fd = l:fd .   "endif\n"
            let l:fd = l:fd . "endfunction"
            execute l:fd



        elseif key == "delete"
call self#log("_cloneObject making delete")
            let l:o.delete = function("self#ObjectDelete")

        else
          if type(a:prototype[key]) == g:self#FUNCREF_TYPE
            " Pass self to the prototype's method
            let l:fd =        "function! l:o." . key . "(...) dict\n"
            let l:fd = l:fd .   "let l:o = self#ObjectManager().lookup(" . a:prototype._id . ")\n"
            let l:fd = l:fd .   "return call(l:o." . key . ", a:000, self)\n"
            let l:fd = l:fd . "endfunction"
            execute l:fd

          elseif type(a:prototype[key]) == g:self#LIST_TYPE
            let l:o[key] = deepcopy(a:prototype[key])

          elseif type(a:prototype[key]) == g:self#DICTIONARY_TYPE
            let l:o[key] = deepcopy(a:prototype[key])

          else
call self#log("_cloneObject value=".a:prototype[key])
            let l:o[key] = a:prototype[key]
          endif
        endif
      endfor

      call self#ObjectManager().store(l:o)

" call self#log("_cloneObject " . l:o._type . "  " . string(l:o))
call self#log("_cloneObject BOTTOM " . l:o._type)
call self#log("_cloneObject BOTTOM id=" . l:o._id)
call self#log("_cloneObject BOTTOM parent._type=" . l:o._prototype._type)
call self#log("_cloneObject BOTTOM parent._id=" . l:o._prototype._id)
call self#log("_cloneObject BOTTOM super._type=" . l:o.super()._type)
call self#log("_cloneObject BOTTOM super._id=" . l:o.super()._id)

      return l:o
    endfunction



    function g:self_ObjectPrototype._deleteType(prototype) dict
      let l:i = stridx(a:prototype._type, "Prototype")
      if l:i == -1
        throw "Should only be called to delete Prototypes, not: " . a:prototype.getType()
      endif
      if g:self_can_delete_prototypes
        call self#PrototypeManager().remove(a:prototype)
        for key in keys(a:prototype)
          unlet a:prototype[key]
        endfor
      else
        throw "Not allowed to delete Prototypes, to enable set g:self_can_delete_prototypes true"
      endif
    endfunction

    function g:self_ObjectPrototype._deleteObject(prototype) dict
call self#log("_deleteObject TOP id=" . a:prototype._id)
      call self#ObjectManager().remove(a:prototype)
      for key in keys(a:prototype)
        unlet a:prototype[key]
      endfor
    endfunction
  endif

  return g:self_ObjectPrototype

endfunction

" ==============
"  Restore:
" ==============
let &cpo= s:keepcpo
unlet s:keepcpo

" ================
"  Modelines:
" ================
" vim: ts=4 fdm=marker
