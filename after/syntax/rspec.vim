let b:spelldir  = '%:.'
let b:spellfile = &spelllang . '.' . &encoding . '.add'

while expand(b:spelldir) !=# '.'
  let b:spelldir = b:spelldir . ':h'
  let b:spellpath = expand(b:spelldir) . '/' . b:spellfile

  if filereadable(b:spellpath)
    execute 'setlocal spellfile-=' . b:spellpath
    execute 'setlocal spellfile^=' . b:spellpath
    if ! filereadable(b:spellpath . '.spl')
      silent execute 'mkspell ' . b:spellpath
    endif
    break
  endif
endwhile

unlet b:spelldir
unlet b:spellfile
unlet b:spellpath
