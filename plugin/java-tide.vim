" The start of a plugin for tag-based java development. There are three features
" here.

" The first does imports from tags, inspired by
" js-file-import: https://github.com/kristijanhusak/vim-js-file-import
"
" The second is smarter tag searching. The idea is to provide tide-versions of
" every vim tag function that does the same thing, except it filters the tag
" list down to only those identifiers in the classpath.
"
" The third is classpath-aware tag completion.
"
" The fundamental idea combining all this functionality is scope-aware
" tags. Adding imports expands the scope where we can find tags. Tag jumping
" and omnicompletion takes advantage of scope awareness to keep the list of
" matching tags small.

"---------------------------- Tag Based Import ---------------------------------
" Takes an identifier, and pulls out all the matching class tags. Then, asks the
" user which one they'd like to import. It converts the directory to a package
" and adds the import to the import section to the appropriate group.
function! Import(tagidentifier)
    let chosen_import = SelectImport(a:tagidentifier)
    if chosen_import == -1
        return
    endif
    let import_statement = "import " . chosen_import . ";"
    let original_search = @/
    if search(import_statement, 'wn')
        echo("\rImport " . chosen_import . " already exists.")
        return
    endif
    let [import_groups, imports_end] = GetImportGroups()
    call AddNewImport(import_groups, chosen_import, import_statement)
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
    let @/ = original_search
endfunction

" Takes a list of lists, and a list of strings. Each entry in import_groups
" represents an import group. Each entry is a list of the packages that make
" up that group. For example, {"java", "net"} represents a group of packages
" that lead with "java.net." The list of strings is a list of packages whose
" group we'd like to determine.
" Returns the group that packages is a member of
function! ExtractGroup(import_groups, packages)
    for group in a:import_groups
        if group == a:packages[:len(group)-1]
            return group
        endif
    endfor
    echo("ERROR: Unknown group " . string(a:packages))
endfunction

" Given a list of import groups, the import to add, and the statement for
" the Java statement for the import to add, adds the import to the appropriate
" group. If the group doesn't exist, adds the import in the appropriate
" position.
function! AddNewImport(import_groups, chosen_import, import_statement)
    " TODO: Pull this out into a user-settable global variable.
    let group_ordering = ["com.flurry", "com.yahoo", "com", "org", "net", "edu", "io", "gnu", "lombok", "java", "javax"]
    let group_ordering = map(group_ordering, 'split(v:val, "\\.")')
    let packages = split(a:chosen_import, '\.')
    let new_import_group = ExtractGroup(group_ordering, packages)
    let added = 0
    for group in a:import_groups
        if len(group) > 0
            " Each statement begins with import, so we need to strip that off,
            " as well as the class names.
            let group_packages = GetPackages(group)
            let group_type = ExtractGroup(group_ordering, group_packages)
            if group_type == new_import_group
                call sort(add(group, a:import_statement))
                let added = 1
                break
            endif
        endif
    endfor
    if !added
        call AddNewGroup(a:import_groups, a:import_statement, new_import_group, group_ordering)
    endif
endfunction

function! GetPackages(import_statements)
    return split(split(a:import_statements[0])[-1], '\.')[:-2]
endfunction

function! AddNewGroup(import_groups, import_statement, new_import_index, group_ordering)
    let new_group_index = index(a:group_ordering, a:new_import_index)
    let added = 0
    for group in a:import_groups
        if len(group)
            let group_packages = GetPackages(group)
            let group_type = ExtractGroup(a:group_ordering, group_packages)
            if index(a:group_ordering, group_type) > new_group_index
                let import_index = index(a:import_groups, group)
                call insert(a:import_groups, [a:import_statement], import_index)
                let added = 1
                break
            endif
        endif
    endfor
    if !added
        call add(a:import_groups, [a:import_statement])
    endif
endfunction

" Given a tagidentifier, asks the user which class they would like to import,
" and returns the fully qualified class name of the selection.
function! SelectImport(tagidentifier)
    let tags = map(FilterTags(a:tagidentifier), 'v:val.tag')
    let tags = uniq(filter(tags, 'index(["c", "i", "e", "g"], v:val["kind"]) > -1'))
    let filenames = map(tags, 'v:val["filename"]')
    let imports = uniq(sort(filter(map(filenames, 'Translate_directory(v:val)'), 'len(v:val)')))
    " let imports = uniq(sort(filter(map(filenames, 'Translate_directory(v:val)'), 'len(v:val)')))
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

" Returns all the imports in the current buffer as a list of lists. Each list
" is a group of imports (i.e. a paragraph) pulled from the buffer.
" Returns a list containing two values: the group of imports in this buffer,
" and the line at which the imports end.
function! GetImportGroups()
    let cursor_position = getcurpos()
    let class_start = search('^\(public\|protected\|private\) \(class\|enum\|interface\)', 'w')
    let class_docs_start = search('/\*\*', 'bWn')
    if class_docs_start > 0
        let imports_end = class_docs_start
    else
        normal gg
        let annotation_start = search('^@', 'Wn')
        if annotation_start > 0 && annotation_start < class_start
            let imports_end = annotation_start
        else
            let imports_end = class_start
        endif
    endif
    call setpos('.', cursor_position)

    let imports = filter(copy(getline(1, imports_end-1)), 'v:val =~ "^import" || v:val =~ "^$"')
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
    return [importgroups, imports_end]
endfunction



let directory_cache = {}
" Takes a filename (as a string), and a dictionary mapping
" identifiers that start a package to something truthy (i.e. a set), and
" returns the fully-qualified Java name of the class.
"
" This function maintains an (ever-growing) in-memory cache of filenames to
" packages to keep repeated lookups fast.
"
" filename: The name of the file to translate into a fully-qualified name
" returns A string containing the fully qualified Java class name to import.
function! Translate_directory(filename)
    let no_extension = fnamemodify(a:filename, ":p:r")
    let classname = fnamemodify(no_extension, ":t")
    if has_key(g:directory_cache, a:filename) > 0
        let package = g:directory_cache[a:filename]
    else
        let package = GetClassPackage(a:filename)
        let g:directory_cache[a:filename] = package
    endif
    return package . "." . classname
endfunction

" Given a filename, returns the package for the Java class in said file.
function! GetClassPackage(filename)
    let package = trim(system("ag --nonumbers --nofilename --silent -m 1 \"^package\" " . a:filename))
    return split(split(package, " ")[1], ";")[0]
endfunction

function! LoadClasspath()
  " TODO: Make this a configuration parameter.
  " Actually, what we *should* do is as part of building the classpath, we augment it with
  " these directories, since these directories are needed by both vim and the scope construction
  " script.
  let classpath = [getcwd(), "/Users/acholewa/sources/java-standard-library", "/Users/acholewa/gozer/flurry/dbAccessLayer/", "/Users/acholewa/work/kafka/connect"]
  if filereadable(".classpath")
    let classpath = extend(classpath, readfile(".classpath"))
  endif
  return classpath
endfunction

let classpath = LoadClasspath()
function! InScope(filename, this_file)
    for path in g:classpath
        if match(a:filename, path) > -1
            " TODO: Make this a configuration parameter
            let search_command = "ag --nonumbers --nofilename --silent -c -m 1 \"^" . a:filename . ".+" . a:this_file . "\" .scope"
            return system(search_command) - 1
        endif
    endfor
    return -1
endfunction

function! LoadClasspath()
    let classpath = [getcwd(), "/Users/acholewa/sources/java-standard-library", "/Users/acholewa/gozer/flurry/dbAccessLayer/", "/Users/acholewa/work/kafka/connect"]
    if filereadable(".classpath")
        let classpath = extend(classpath, readfile(".classpath"))
    endif
    return classpath
endfunction

let classpath = LoadClasspath()

let inscope_caches = {}
" Given an identifier, returns a dictionary containing two entries:
" 1. tag - A tag that matches the passed in identifier, and is in this project's classpath.
" 2. taglistindex - The tag's original index in the taglist. This allows us to use
" `taglistindex`tag to immediately jump to this tag and add it to the tagstack.
function! FilterTags(identifier)
    let cwd = getcwd()
    if has_key(g:inscope_caches, cwd) <= 0
        let g:inscope_caches[cwd] = {}
    endif
    let tag_cache = g:inscope_caches[cwd]
    let tags = taglist("^" . a:identifier . "$", @%)
    let filteredtags = []
    let index = -1
    for tag in tags
        let index = index + 1
        if tag.filename ==# @%
           let filteredtags = add(filteredtags, {"tag": tag, "taglistindex": index})
        elseif has_key(tag_cache, tag.filename) > 0
            if tag_cache[tag.filename] > -1
                let filteredtags = add(filteredtags, {"tag": tag, "taglistindex": index})
            endif
        else
            for path in g:classpath
                if match(tag.filename, path) > -1
                    let tag_cache[tag.filename] = 1
                    let filteredtags = add(filteredtags, {"tag": tag, "taglistindex": index})
                    break
                endif
            endfor
            if has_key(tag_cache, tag.filename) <= 0
                let tag_cache[tag.filename] = -1
            endif
        endif
    endfor
    return filteredtags
endfunction

function! TideJumpTag(identifier, count, bang)
    let filteredTags = FilterTags(a:identifier)
    if len(filteredTags) == 0
        echom("No tags found.")
        return
    endif
    let index = max([a:count, len(filteredTags) - 1])
    let tag = filteredTags[index]
    execute tag.taglistindex . "tag" . a:bang . " " . a:identifier
endfunction

function! TideTselect(identifier, bang)
    let filteredTagsIndices = FilterTags(a:identifier)
    if len(filteredTagsIndices) == 0
        echom("No tags found.")
        return
    endif
    " TODO: Pull this out into a configuration parameter.
    let todisplay = map(copy(filteredTagsIndices), 'v:key . "\t" . v:val.tag.kind . "\t" . v:val.tag.name . "\t" . v:val.tag.filename . "\n\t\t" . trim(v:val.tag.cmd[2:-3])') " Strip characters used by the search command.
    let tagliststring = join(todisplay, "\n") . "\n"
    let selection = input(tagliststring)
    if selection ==# "q" || selection ==# ""
        return
    endif
    let tag = filteredTagsIndices[selection]
    execute tag.taglistindex . "tag" . a:bang . " " . a:identifier
endfunction

command! -nargs=1 TideClassName call Translate_directory("<args>")
command! -nargs=1 -complete=tag TideImport call Import("<args>")
command! -nargs=1 -complete=tag -count -bang Tidetag call TideJumpTag("<args>", "<count>", "<bang>")
command! -nargs=1 -complete=tag -bang Tidetselect call TideTselect("<args>", "<bang>")
