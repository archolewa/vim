" The start of a plugin for tag-based development. There are two features here.
" The first, does imports from tags, inspired by 
" js-file-import: https://github.com/kristijanhusak/vim-js-file-import
" The second is an omni-complete function that uses tag completion, but then 
" narrows those tags down based on scope.

" Takes an identifier, and pulls out all the matching tags. Then, asks the 
" user which one they'd like to import. It converts the directory to a package
" accordingly, and appends the import to the import section. It also filters
" down to just classes, since that's the only thing we're importing.
function! Import(tagidentifier)
    let tags = taglist('^' . a:tagidentifier . '$')
    let tags = uniq(filter(tags, 'v:val["kind"] == "c"'))
    let todisplay = map(copy(tags), 'v:key . " " . v:val["filename"]')
    let tagliststring = join(todisplay, "\n") . "\n"
    let inputstring = "Select class to import: \n" . tagliststring
    let selection = input(inputstring)
    if selection ==# ""
        return
    endif
    let chosenimport = tags[selection]
    let filename = chosenimport["filename"]
    " Hard coded right now, but this should really be a configuration parameter.
    let package_start = ["com", "org", "net", "java", "javax", "yjava"]
endfunction
