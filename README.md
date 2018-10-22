# Schematique
Graphviz preprocessor for simpler flowcharting

# Aims

In order of importance/general interest:
- automate word-wrap
- simplify syntax (trade some flexibility for readability)
- enable a powerful "format presets" system. (e.g. tag a node with `{objection}` for a red border, tag it with `{support}` for a green border, etc.)

# The Syntax

- for nodes: `node_name [label = "Lots of nice text." {default}]`
  - becomes: `node_name [label = "Lots of nice text.", color = blue, shape = rectangle, style = rounded, penwidth = 3, style = solid]`
- for edges: `node1 -> node2 {{default}}`
  - becomes: `node1 -> node2 [color = blue, style = solid]`

This is of course customisable.
