# Schematique
Graphviz preprocessor for simpler flowcharting

# Aims

In order of importance/general interest:
- automate word-wrap
- simplify syntax (for some definitions of "simplify"), **especially for tables**.
- enable a powerful "format presets" system. (e.g. tag a node with `{objection}` for a red border, tag it with `{support}` for a green border, etc.)

# Requirements

Schematique requires:
- GraphViz (for all the real work)
- Inkscape (for SVG to PDF conversion)

# Word-wrapping

This is controlled through the variable `LINE_LENGTH`, which is currently set at `40` characters. The parser adds a `<BR/>` after every `40` (or whatever you want) characters. You can put in your own breaks manually and it work to complement them nicely (i.e. it starts counting again if it encounters a break already in the text).

Word-wrapping is also performed on lines in tables. A basic variable (`TABLE_LINE_BASE`) is used, but multiplied according to the number of columns the cell spans.

# The Syntax

## Customisable presets

- for nodes: `node_name [label = "Lots of nice text." {default}]`
  - becomes: `node_name [label = "Lots of nice text.", color = blue, shape = rectangle, style = rounded, penwidth = 3, style = solid]`
- for edges: `node1 -> node2 {{default}}`
  - becomes: `node1 -> node2 [color = blue, style = solid]`

## Tables in Nodes

It is hard to have a syntax for tables that is both powerful (allowing for both colspan and rowspan) and markdown-like in its user-friendliness. This is an attempt to strike a balance between the two.

- Tables open with a line containing the node_name, followed in the next line by `<TABLE`. Formatting like borders is handled using presets, except for color.
- The table is closed with `</TABLE>` (nothing more is needed --- it is handled through presets).

- Think in terms of rows rather than columns.
  - each row is opened with `+==` and closed with `==+`
  - for convenience and readability, every row boundary except for the top and bottom of the table is indicated by `==++==`.

The syntax permits colspan:

- cells are opened by `+` followed either by one `-` or by a number of pipe symbols (`|`). 
    - `+-` opens a cell spanning one column
    - `+|||` opens a cell spanning three columns
    - cells are closed with the mirror-image of their opening: e.g. `-+` or `|||+`

Here is a fairly simple table. The syntax is not fully intuitive, but better than trying to write HTML tables.

~~~
Three_things 
<TABLE COLOR="BLUE">
+==
  +||| BORDER="0">A List of Three Things|||+
==++==
  +- COLOR="darkgreen" PORT="first_thing">First Thing-+
  +- COLOR="orange" PORT="second_thing">Second Thing-+
  +- COLOR="red" PORT="third_thing">Third Thing-+
==+
</TABLE>
~~~

We can also create tables with row-span:
- Here, we indicate the number of rows the cell spans with the number of `-` after the `+`
  - `+---` spans three rows.
- Again, we close the cell with the mirror-image of the opening: `---+`

Once again, the table is not immediately intuitive, but doesn't get in the way too much.

~~~
Four_Things
<TABLE COLOR="FORESTGREEN">
+==
  +|| BORDER="0">Four Things||+
==++==
  +---->Here are four things----+
  +->The first thing-+
==++==
  +->The second thing-+
==++==
  +->The third thing-+
==++==
  +->The fourth thing-+
==+
</TABLE>
~~~
