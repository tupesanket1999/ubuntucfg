"KeyRemaps
"
inoremap jj <esc>
nnoremap zz :w<CR>
nnoremap zq :bp<bar>sp<bar>bn<bar>bd<CR>

nnoremap <leader>h :wincmd h<CR>                                                
nnoremap <leader>j :wincmd j<CR>                                                
nnoremap <leader>k :wincmd k<CR>                                                
nnoremap <leader>l :wincmd l<CR>

nnoremap <C-k> :bn<CR>
nnoremap <C-j> :bp<CR>

"RESIZE
nnoremap <Leader>+ :vertical resize +5<CR>                                      
nnoremap <Leader>- :vertical resize -5<CR>

"SPLIT SCREEN
nnoremap <C-w>s :belowright split<CR>
nnoremap <C-w>v :belowright vsplit<CR>

"TERMINAL
nnoremap <leader>t :terminal<CR>

"UNDOTREE
nnoremap <leader>u :UndotreeShow<CR>

"TERMINAL
tnoremap <Esc> <C-\><C-n>

"DIAGNOSTICS
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle lsp_workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle lsp_document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
nnoremap <leader>xr <cmd>TroubleToggle lsp_references<cr>

"LSPSAGA
"nnoremap <silent>K :Lspsaga hover_doc<CR>
"nnoremap <silent><leader>gh <cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>
"nnoremap <silent><leader>a :Lspsaga code_action<CR>
"nnoremap <silent><leader>rn :Lspsaga rename<CR>
"nnoremap <silent> [e :Lspsaga diagnostic_jump_next<CR>
"nnoremap <silent> ]e :Lspsaga diagnostic_jump_prev<CR>
"nnoremap <silent> <A-d> :Lspsaga open_floaterm<CR>
"tnoremap <silent> <A-d> <C-\><C-n>:Lspsaga close_floaterm<CR>

"AUTO COMPLETE
inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm({ 'keys': "\<Plug>delimitMateCR", 'mode': '' })
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

"TELESCOPE
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fa <cmd>Telescope find_files find_command=rg,--ignore,--hidden,--files cwd=~<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr> Find files using Telescope command-line sugar.
nnoremap <leader>fc <cmd>lua require('telescope.builtin').commands()<cr>
nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input(" > ")})<CR>
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>
nnoremap <silent><leader>gr <cmd>lua require"telescope.builtin.lsp".references()<CR>

"NERD TREE
nnoremap <C-n> :NvimTreeToggle<CR>
