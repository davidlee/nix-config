The `doctrine slice plan` scaffold's header comment reads "One [[phase]] per
ordered phase". A script that splices at the first `[[phase]]` substring
inserts phase keys into the preceding table (`[requirements]`), so
`doctrine slice phases` silently materialises only the later phases and
`slice status` shows a short phase count. Check with
`python3 -c "import tomllib; print([p['id'] for p in tomllib.load(open(P,'rb'))['phase']])"`.

Inline tables (`{ id = "VT-1", … }`) must stay on one line: a newline inside
one is a parse error ("invalid inline table, expected `}`").
