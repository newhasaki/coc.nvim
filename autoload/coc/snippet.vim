let s:is_vim = !has('nvim')
let s:bufnr = 0

" make a range to select mode
function! coc#snippet#range_select(lnum, col, len) abort
  let m = mode()
  if a:len > 0 && m ==# 'i'
    stopinsert
  endif
  call timer_start(20, { -> s:start_select(a:lnum, a:col, a:len)})
endfunction

function! s:start_select(lnum, col, len)
  let virtualedit = &virtualedit
  let &virtualedit = 'onemore'
  call cursor(a:lnum, a:col)
  if a:len > 0
    let m = a:len == 1 ? '' : (a:len - 1).'l'
    execute 'normal! v'.m. "\<C-g>"
  endif
  if a:len == 0 && mode() !=# 'i'
    call feedkeys('i', 'in')
  endif
  let &virtualedit = virtualedit
endfunction

function! coc#snippet#show_choices(lnum, col, len, values) abort
  let m = mode()
  call cursor(a:lnum, a:col + a:len)
  if m !=# 'i' | startinsert | endif
  let g:coc#_context = {
        \ 'start': a:col - 1,
        \ 'candidates': map(a:values, '{"word": v:val}')
        \}
  call timer_start(20, { -> coc#_do_complete()})
endfunction

function! coc#snippet#enable()
  let s:bufnr = bufnr('%')
  let nextkey = get(g:, 'coc_snippet_next', '<C-j>')
  let prevkey = get(g:, 'coc_snippet_prev', '<C-k>')
  nnoremap <buffer> <esc> :call CocActionAsync('snippetCancel')<cr>
  execute 'imap <buffer> <nowait> <silent>'.prevkey." <C-o>:call CocActionAsync('snippetPrev')<cr>"
  execute 'smap <buffer> <nowait> <silent>'.prevkey." <Esc>:call CocActionAsync('snippetPrev')<cr>"
  execute 'imap <buffer> <nowait> <silent>'.nextkey." <C-o>:call CocActionAsync('snippetNext')<cr>"
  execute 'smap <buffer> <nowait> <silent>'.nextkey." <Esc>:call CocActionAsync('snippetNext')<cr>"
endfunction

function! coc#snippet#disable()
  if bufnr('%') != s:bufnr
    return
  endif
  let nextkey = get(g:, 'coc_snippet_next', '<C-j>')
  let prevkey = get(g:, 'coc_snippet_prev', '<C-k>')
  silent! nunmap <buffer> <esc>
  silent! execute 'iunmap <buffer> <silent> '.prevkey
  silent! execute 'sunmap <buffer> <silent> '.prevkey
  silent! execute 'iunmap <buffer> <silent> '.nextkey
  silent! execute 'sunmap <buffer> <silent> '.nextkey
endfunction
