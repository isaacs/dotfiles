noremap J <C-e>
noremap K <C-y>
noremap H zhzh
noremap L zlzl
let g:go_doc_keywordprg_enabled = 0

" Specify a directory for plugins
call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-fugitive'
" Plug 'godlygeek/tabular'
Plug 'tpope/vim-sensible'
Plug 'jonsmithers/vim-html-template-literals'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'mbbill/undotree'
Plug 'tpope/vim-markdown'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'jparise/vim-graphql'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'prettier/vim-prettier'
Plug 'jxnblk/vim-mdx-js'
Plug 'skanehira/gh.vim'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
call plug#end()

if has("persistent_undo")
  set undodir=$HOME/.undodir
  set undofile
endif

" Markdown tweaks
let g:vim_markdown_fenced_languages = ['js=javascript', 'sh=bash', 'md=markdown', 'html', 'ts=typescript']
let g:markdown_fenced_languages = ['js=javascript', 'sh=bash', 'html', 'ts=typescript']
let g:markdown_frontmatter = 1
let g:markdown_enable_spell_checking = 0
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_auto_insert_bullets = 1
"set conceallevel=2
"let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_new_list_item_indent = 4


" i've got lots of ram and markdown has some big greps
set maxmempattern=10000
set nu
set encoding=utf-8
let mapleader=","

" Whitespace stuff
set nowrap
set list listchars=tab:\ \ ,trail:·
set nofoldenable

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Tab completion
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc

" Status bar
" set laststatus=2

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" load the plugin and indent settings for the detected filetype
filetype plugin indent on

" Use modeline overrides
set modeline
set modelines=10

" Default color scheme
color default

set regexpengine=1
syntax enable

set mouse=a
if &term =~ '^screen' && !has('nvim')
  " tmux knows the extended mouse mode
  set ttymouse=xterm2
endif
if !has('nvim')
  set term=xterm-256color
endif
set ruler
color fruit
color camo
color desertEx
color moria
" color earendel
" color monokai

" when using a projector, use a light color scheme and no syntax
function Pres ()
  :colorscheme dawn
  :syntax off
endfunction
map <Leader>pres :call Pres()<CR>

function Mdflat ()
  " TODO: avoid reformatting ``` sections somehow?
  :%s/\v\n(\s)+([^-* ])/ \2/g
  :%s/\v([^\n])\n([^-* #\n])/\1 \2/g
endfunction

command! -range DY call DateYaml()
function DateYaml ()
  read !echo "date: $(node -p 'new Date().toISOString()')"
endfunction
function YamlDate ()
  call DateYaml()
endfunction
map <Leader>dy :DY<CR>

function PrettyJSON ()
  w
  !j %
endfunction
command! J :call PrettyJSON()

set hls
noremap <Leader><Space> :noh<CR>:call clearmatches()<CR>:syntax sync fromstart<CR>

noremap <Leader>. :%s/\v +$//g<CR>

" this makes it use the system clipboard
" whenever yanking to the "unnamed" register.
set clipboard=unnamed

set wrap
" set modelines=0
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set ttyfast
set autoindent
set showmode
set showcmd
"set visualbell
nnoremap / /\v
vnoremap / /\v
if exists("&colorcolumn")
  set colorcolumn=80
endif
nnoremap j gj
nnoremap k gk

" make xX use the "x" register, rather than the default register
" d already deletes and yanks to the default register
noremap x "xx
noremap X "xX

" make cC yank to the "c" register.
" it's rare that you want to correct and then re-paste, but possible.
noremap c "cc
noremap C "cC

" this bit makes Q, W and WQ work just like their lowercase counterparts
com -bang Q q<bang>
com -bang W w<bang> <args>
com -bang WQ wq<bang> <args>
com -bang Wq wq<bang> <args>
com -bang WQa wqa<bang> <args>
com -bang Wqa wqa<bang> <args>
com -bang WQA wqa<bang> <args>

" super annoying typos if you maintain a pacakge manager
iab pacakges packages
iab pacakge package
iab depdencies dependencies
iab verison version
iab verisons versions
iab nodE_modules node_modules
iab teh the
iab hte the
iab wiht with
iab eaisly easily
iab ofr for

" shift to move the window, not the cursor.
inoremap JJJJ <Esc><C-e><C-e><C-e>
inoremap KKKK <Esc><C-y><C-y><C-y>
inoremap HHHH <Esc>zhzhzhzhzhzh
inoremap LLLL <Esc>zlzlzlzlzlzl

" control to switch windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l
inoremap <C-j> <C-w>j
inoremap <C-k> <C-w>k
inoremap <C-h> <C-w>h
inoremap <C-l> <C-w>l

" f1, you are my nemesis.
map <F1> <Esc>
imap <F1> <Esc>

" escape is so far away
noremap <Leader>m <Esc>
inoremap <Leader>m <Esc>

" prisma is graphql with // comments
" just add // as a comment, even though graphql doesn't do that
au! BufNewFile,BufRead,BufNewFile *.prisma setlocal filetype=graphql
au FileType graphql syn match prismaComment "//.*$" contains=@Spell
au FileType graphql hi def link prismaComment Comment

" nunjucks is basically html
au! BufNewFile,BufRead,BufNewFile *.njk setlocal filetype=html

" italic comments
set t_ZH=[3m
set t_ZR=[23m
highlight Comment cterm=italic gui=italic

" go stuff
let g:go_list_type = "quickfix"
let g:go_fmt_command = "goimports"
let g:go_test_show_name = 1
let g:go_template_autocreate = 0
" let g:go_auto_type_info = 1 -- uncomment when fixed after go1.18 release
" set updatetime=100

let g:coc_global_extensions = ['coc-tsserver', 'coc-json']
" Add CoC Prettier if prettier is installed
" if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
"   let g:coc_global_extensions += ['coc-prettier']
" endif
nmap <leader>gn <Plug>(coc-diagnostic-prev)
nmap <leader>gm <Plug>(coc-diagnostic-next)
nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gy <Plug>(coc-type-definition)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gr <Plug>(coc-references)
function! ToggleCocDoc()
  if coc#float#has_float()
    call coc#float#close_all()
  else
    if CocAction('hasProvider', 'hover')
      call CocActionAsync('definitionHover')
    endif
  endif
endfunction
nmap <leader>, :call ToggleCocDoc()<CR>
nmap <leader>f :%!npx prettier --stdin-filepath %<CR>:syntax sync fromstart<CR>
autocmd FileType typescript nmap <leader>f :call CocAction('runCommand', 'editor.action.organizeImport')<CR>:%!npx prettier --stdin-filepath %<CR>:syntax sync fromstart<CR>
autocmd FileType typescriptreact nmap <leader>f :call CocAction('runCommand', 'editor.action.organizeImport')<CR>:%!npx prettier --stdin-filepath %<CR>:syntax sync fromstart<CR>
" tab autocompletes if menu showing, otherwise it's just tab
inoremap <silent><expr> <tab> pumvisible() ? coc#_select_confirm() : "<TAB>"

hi Pmenu term=reverse ctermfg=252 ctermbg=52 guifg=fg guibg=#600000
hi ToolbarLine term=reverse ctermfg=252 ctermbg=52 guifg=fg guibg=#600000
hi CocListBgWhite term=reverse ctermfg=252 ctermbg=52 guifg=fg guibg=#600000
hi CocListBgGrey term=reverse ctermfg=252 ctermbg=52 guifg=fg guibg=#600000
hi Conceal term=reverse ctermfg=252 ctermbg=52 guifg=fg guibg=#600000
hi FgCocWarningFloatBgCocFloating term=reverse ctermfg=252 ctermbg=52 guifg=fg guibg=#600000
hi FgCocHintFloatBgCocFloating term=reverse ctermfg=252 ctermbg=52 guifg=fg guibg=#600000
hi FgCocErrorFloatBgCocFloating ctermfg=9 ctermbg=bg guifg=#ff0000 guibg=#330000 term=reverse

" golang
autocmd FileType go nmap <buffer> <Leader>c <Plug>(go-coverage-toggle)
autocmd FileType go nmap <buffer> <Leader>r <Plug>(go-run)
autocmd FileType go nmap <buffer> <Leader>b <Plug>(go-build)
autocmd FileType go nmap <buffer> <Leader>t <Plug>(go-test)
autocmd FileType go nmap <buffer> <Leader>ds <Plug>(go-def)
autocmd FileType go nmap <buffer> <Leader>e <Plug>(go-iferr)
autocmd FileType go nmap <buffer> <Leader>f <Plug>(go-fmt)
" autocmd FileType go nmap <buffer> <Leader>v :GoDeclsDir<CR>
autocmd FileType go nmap <buffer> <Leader>p :cexpr system('go test')<CR>:copen<CR>

" markdown uses 4-space indentation for lists, so make that easier.
" also use a narrower text width on markdown, since it's usually a
" lot of prose.
au FileType markdown setlocal textwidth=65
" au FileType markdown setlocal tabstop=4
" au FileType markdown setlocal shiftwidth=4
" au FileType markdown setlocal softtabstop=4
au FileType markdown.mdx setlocal textwidth=65
" au FileType markdown.mdx setlocal tabstop=4
" au FileType markdown.mdx setlocal shiftwidth=4
" au FileType markdown.mdx setlocal softtabstop=4

function! CheckBox ()
  let line = getline('.')
  " call setline('.', substitute(line, '$', ' -- eol', ''))
  if (match(line, '^\s*[*-]') != -1)
    " is a li
    if (match(line, '^\s*[*-] \[[x ]\]') == -1)
      " not a checkbox
      if (match(line, '^\s*-') != -1)
        call setline('.', substitute(line, '-\s*', '- [ ] ', ''))
      else
        call setline('.', substitute(line, '*\s*', '* [ ] ', ''))
      endif
      normal 4l
    else
      " is a checkbox, check open/closed
      if (match(line, '^\s*[*-] \[ \]') != -1)
        " open, close it
        call setline('.', substitute(line, '\[ \] ', '[x] ', ''))
      else
        " closed, remove it
        let s = col('.')
        call setline('.', substitute(line, '\[x\] ', '', ''))
        let t = col('.')
        while (s - t < 4)
          normal h
          let s += 1
        endwhile
      endif
    endif
  endif
endfunction
au FileType markdown nnoremap <buffer><silent> <space> :call CheckBox()<CR>
au FileType markdown vnoremap <buffer><silent> <space> :call CheckBox()<CR>
au FileType markdown.mdx nnoremap <buffer><silent> <space> :call CheckBox()<CR>
au FileType markdown.mdx vnoremap <buffer><silent> <space> :call CheckBox()<CR>

function! CheckBoxJS ()
  let line = getline('.')
  " call setline('.', substitute(line, '$', ' -- eol', ''))
  if (match(line, '^\s*// \s*[*-]') != -1)
    " is a li
    if (match(line, '^\s*// \s*[*-] \[[x ]\]') == -1)
      " not a checkbox
      if (match(line, '^\s*// \s*-') != -1)
        call setline('.', substitute(line, '-\s*', '- [ ] ', ''))
      else
        call setline('.', substitute(line, '*\s*', '* [ ] ', ''))
      endif
      normal 4l
    else
      " is a checkbox, check open/closed
      if (match(line, '^\s*// \s*[*-] \[ \]') != -1)
        " open, close it
        call setline('.', substitute(line, '\[ \] ', '[x] ', ''))
      else
        " closed, remove it
        let s = col('.')
        call setline('.', substitute(line, '\[x\] ', '', ''))
        let t = col('.')
        while (s - t < 4)
          normal h
          let s += 1
        endwhile
      endif
    endif
  endif
endfunction
au FileType typescript nnoremap <buffer><silent> <space> :call CheckBoxJS()<CR>
au FileType typescript vnoremap <buffer><silent> <space> :call CheckBoxJS()<CR>
au FileType typescriptreact nnoremap <buffer><silent> <space> :call CheckBoxJS()<CR>
au FileType typescriptreact vnoremap <buffer><silent> <space> :call CheckBoxJS()<CR>
au FileType javascript nnoremap <buffer><silent> <space> :call CheckBoxJS()<CR>
au FileType javascript vnoremap <buffer><silent> <space> :call CheckBoxJS()<CR>

" languages that use real tabs
set expandtab
au FileType make setlocal noexpandtab
au FileType python setlocal noexpandtab
au FileType go setlocal noexpandtab

noremap <leader>z :UndotreeToggle<CR>

if has('nvim')
  command! Sh sp|te
endif

" don't ever get confused and think the whole rest of the file is a comment
autocmd BufEnter * :syntax sync fromstart

set directory=~/.vim/swapfiles//
