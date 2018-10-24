" The start of a plugin for tag-based development. There are three features 
" here.
"
" The first does imports from tags, inspired by 
" js-file-import: https://github.com/kristijanhusak/vim-js-file-import
"
" The second is smarter tag matching. The idea is to provide tide-versions of
" every vim tag function that does the same thing, except it filters the tag
" list down to only those identifiers the current file can actually see.
"
" The third is an omni-complete function that uses tag completion, but then 
" narrows those tags down based on scope.
"
" The fundamental idea combining all this functionality is scope-aware
" tags. Adding imports expands the scope where we can find tags. Tag jumping
" and omnicompletion takes advantage of scope awareness to keep the list of 
" matching tags small.


" Takes an identifier, and pulls out all the matching class tags. Then, asks the 
" user which one they'd like to import. It converts the directory to a package
" accordingly, and appends the import to the import section. It also filters
" down to just classes, since that's the only thing we're importing.
function! Import(tagidentifier)
    let tags = taglist('^' . a:tagidentifier . '$')
    let tags = uniq(filter(tags, 'v:val["kind"] == "c"'))
    let filenames = map(tags, 'v:val["filename"]')
    let imports = map(filenames, 'Translate_directory(v:val)')
    let imports = uniq(imports)
    let todisplay = map(copy(imports), 'v:key . " " . v:val')
    let tagliststring = join(todisplay, "\n") . "\n"
    let inputstring = "Select class to import: \n" . tagliststring

    let selection = input(inputstring)
    if selection ==# ""
        return
    endif
    let chosen_import = imports[selection]
    let cursor_position = getpos(".")
    call cursor(line('$'), 1)
    if search("^import " . chosen_import . ";", 'bn') 
        echo("\rImport " . chosen_import . " already exists.")
        return
    endif
    echo(getpos("."))
    let import_end = search("^import", 'bn')
    call append(import_end, "import " . chosen_import . ";")
    call cursor(cursor_position)
endfunction

" Takes a filename (as a string), and a dictionary mapping 
" identifiers that start a package to something truthy (i.e. a set), and 
" returns the fully-qualified Java name of the class.
"
" We trim the filename down to just the part of the directory that begins with
" one of the package_start strings , and replaces all slashes with periods. Note
" that we search starting from the tail of the filename. 
" For example, when searching the filename "java/lang/String.java", we start
" searching from 'String.java'. This allows customers to put their packages 
" arbitrarily deeply nested under who knows what without unexpected behavior
" if one of the intermediary directories just so happens to be "java" or 
" something.
"
" filename: The name of the file to translate into a fully-qualified name
" 
" returns A string containing the fully qualified Java class name to import.
function! Translate_directory(filename)
    " Hard coded right now, but this should really be a configuration parameter.
    let package_starts = {"com":1, "org":1, "net":1, "java":1, "javax":1, "yjava":1}
    let no_extension = fnamemodify(a:filename, ":p:r")
    let classname = fnamemodify(no_extension, ":t")
    let components = reverse(split(fnamemodify(no_extension, ":h"), "/"))
    let package_components = []
    for component in components
        call add(package_components, component)
        if get(package_starts, component, 0)
            break
        endif
    endfor
    let package_components = reverse(package_components) + [classname]
    return join(package_components, ".")
endfunction
