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
" and adds the import to the import section to the appropriate group.
function! Import(tagidentifier)
    let chosen_import = SelectImport(a:tagidentifier)
    if chosen_import == -1
        return
    endif
    let import_statement = "import " . chosen_import . ";"
    if search(import_statement, 'wn')
        echo("\rImport " . chosen_import . " already exists.")
        return
    endif
    let cursor_position = getcurpos()
    let class_start = search('^\(public\|protected\|private\) \(class\|enum\|interface\)', 'w')
    let class_docs_start = search('/\*\*', 'bWn')
    call setpos('.', cursor_position)
    if class_docs_start > 0 
        let imports_end = class_docs_start
    else
        let imports_end = class_start
    endif
    let import_groups = GetImportGroups(imports_end)
    " TODO: Relying on just the leading package isn't sufficient for e.g.
    " com.flurry. We'll need to pull off the packages that match an entry
    " in the to-be-defined package ordering, and use that instead.
    let leadingpackage = split(chosen_import, '\.')[0]
    let added = 0
    for group in import_groups
        if len(group) > 0
            " Each statement begins with import, so we need to strip that off.
            if split(split(group[0])[1], '\.')[0] ==# leadingpackage
                call sort(add(group, import_statement))
                let added = 1
                break
            endif
        endif
    endfor
    if !added
        call AddNewGroup(import_groups, [import_statement])
    endif
    let import_statements = []
    for group in import_groups
        for import in group
            call add(import_statements, import)
        endfor
        call add(import_statements, '')
    endfor
    let package_location = search("^package", 'wn')
    call deletebufline("%", package_location+1, imports_end-1)
    call append(package_location, import_statements)
endfunction

" TODO: Enhance this function so that we add the new group in the correct
" spot in the list relative to the other groups.
function! AddNewGroup(import_groups, import_group)
    return add(a:import_groups, a:import_group)
endfunction

" Given a tagidentifier, asks the user which class they would like to import,
" and returns the fully qualified class name of the selection.
function! SelectImport(tagidentifier)
    let tags = taglist('^' . a:tagidentifier . '$')
    let tags = uniq(filter(tags, 'index(["c", "i", "e"], v:val["kind"]) > -1'))
    let filenames = map(tags, 'v:val["filename"]')
    let imports = uniq(sort(map(filenames, 'Translate_directory(v:val)')))
    if len(imports) == 1
        return imports[0]
    else
        let todisplay = map(copy(imports), 'v:key . " " . v:val')
        let tagliststring = join(todisplay, "\n") . "\n"
        let inputstring = "Select class to import: \n" . tagliststring
        let selection = input(inputstring)
        if selection ==# ""
            return -1
        endif
        return imports[selection]
    endif
endfunction

" Returns a list of lists. Each list is a group of imports (i.e. a paragraph)
" pulled from the buffer.
function! GetImportGroups(imports_end)
    let imports = filter(copy(getline(1, a:imports_end-1)), 'v:val =~ "^import" || v:val =~ "^$"')
    let importgroups = []
    let currentgroup = []
    for line in imports
        if line =~ '^$'
            call add(importgroups, currentgroup)
            let currentgroup = []
        else
            call add(currentgroup, line)
        endif
    endfor
    return importgroups
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
    " Once we make this a configuration parameter, we'll need to copy the 
    " parameter before we do anything with it.
    let package_starts = {"com":1, "org":1, "net":1, "java":1, "javax":1, "yjava":1, "io":1, "lombok":1}
    let no_extension = fnamemodify(a:filename, ":p:r")
    let classname = fnamemodify(no_extension, ":t")
    let components = reverse(split(fnamemodify(no_extension, ":h"), "/"))
    " A horrible hack, because the Java standard library has a java.io 
    " and java.net package. This modifies package_starts, so we'll need to make 
    " a copy once we make this a config parameter.
    if index(components, "java-standard-library") > -1 || index(components, "openjdk8") > -1
        call remove(package_starts, "net")
        call remove(package_starts, "io")
    endif 
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
