"Golang configs
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1

"Go auto import
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"

" Status line types/signatures
let g:go_auto_type_info = 1

"Autocomplete for vim
let g:go_code_completion_enabled = 1

"run go
nnoremap <leader>go :GoRun<CR>
