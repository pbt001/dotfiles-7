" FIXME: this is current bugged due to conflicting tpope plugin
" rename current file, via Gary Bernhardt
function! general#RenameFile()
  let l:old_name = expand('%')
  let l:new_name = input('New file name: ', expand('%'))
  if l:new_name !=# '' && l:new_name != l:old_name
    execute ':Rename ' . l:new_name
    redraw!
  endif
endfunction

" NOTE: copied from Damian Conway's vimrc
" SOURCE: https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/.vimrc
function! AskQuit (msg, options, quit_option)
  if confirm(a:msg, a:options) == a:quit_option
    exit
  endif
endfunction

" NOTE: copied from Damian Conway's vimrc
" SOURCE: https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/.vimrc
function! general#EnsureDirExists ()
  let l:required_dir = expand('%:h')
  if !isdirectory(l:required_dir)
    call AskQuit("Parent directory '" . l:required_dir . "' doesn't exist.",
      \       "&Create it\nor &Quit?", 2)
    try
      call mkdir(l:required_dir, 'p')
    catch
      call AskQuit("Can't create '" . l:required_dir . "'",
        \            "&Quit\nor &Continue anyway?", 1)
    endtry
  endif
endfunction


" NOTE: copied from Damian Conway's vimrc
" SOURCE: https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/.vimrc
function! general#UndoubleCompletions()
  let l:col = getpos('.')[2]
  let l:line = getline('.')
  call setline('.', substitute(l:line, '\(\k\+\)\%'.l:col.'c\zs\1', '', ''))
endfunction

" NOTE: copied from Damian Conway's vimrc
" SOURCE: https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/.vimrc
function! general#HLNext(blinktime)
  let l:target_pat = '\c\%#'.@/
  let l:ring = matchadd('CurrentSearchMatch', l:target_pat, 101)
  redraw
  exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
  call matchdelete(l:ring)
  redraw
endfunction


function! general#Preserve(command)
  " Preparation: save last search, and cursor position.
  let l:s = @/
  let l:l = line('.')
  let l:c = col('.')

  " Do the business unless filetype is blacklisted
  let l:blacklist = ['sql']

  if index(l:blacklist, &filetype) < 0
    execute a:command
  endif

  " Clean up: restore previous search history, and cursor position
  let @/ = l:s
  call cursor(l:l, l:c)
endfunction

" save session
function! general#WriteSession()
  let l:cwd = fnamemodify('.', ':p:h:t')
  " let dateStamp = strftime("%d-%m-%Y_%H:%M")
  let l:extension = '.session'
  " let fname = cwd . "_" . dateStamp . extension
  let l:fname = l:cwd . l:extension
  silent execute ':Obsession ' . l:fname
  echo 'Wrote ' . l:fname
endfun

function! general#ExecVisualSelection()
  let l:selection = s:get_visual_selection()
  call jobstart("open " . l:selection)
endfunc

" source: http://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript#6271254
" original author of this function: xolox
function! s:get_visual_selection()
  " Why is this not a built-in Vim script function?!
  let [l:lnum1, l:col1] = getpos("'<")[1:2]
  let [l:lnum2, l:col2] = getpos("'>")[1:2]
  let l:lines = getline(l:lnum1, l:lnum2)
  let l:lines[-1] = l:lines[-1][: l:col2 - (&selection ==# 'inclusive' ? 1 : 2)]
  let l:lines[0] = l:lines[0][l:col1 - 1:]
  return join(l:lines, '\n')
endfunction

" Execute macro over visual selection
function! general#ExecuteMacroOverVisualRange()
  echo '@'.getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

" NOTE: copied from Damian Conway's vimrc
" SOURCE: https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/.vimrc
function! general#MarkMargin(on)
  if exists('b:MarkMargin')
      try
          call matchdelete(b:MarkMargin)
      catch /./
      endtry
      unlet b:MarkMargin
  endif
  if a:on
      let b:MarkMargin = matchadd('ColorColumn', '\%>100v\s*\S', 100)
  endif
endfunction

function! general#ErrorMode()
  let l:alestats = ale#statusline#Count(bufnr('%'))
  if l:alestats['error'] > 0
    setlocal nocursorline nocursorcolumn
    setlocal winhl=Normal:ALEErrorBg,TabLineSel:AleErrorBg,TabLine:ALEErrorBg,LineNr:AleErrorBg,CursorLineNr:AleErrorLine
  else
    setlocal winhl=
  endif
endfunction
