module FlowchartKeywords
  
  TABLE_BORDER_THICKNESS = 3
  
  EDGE_KEYS = { # You can override these defaults either here or in your .gv document itself by respecifying the same parameters, just afterwards. (i.e. `{title}, color = orange`)
    "default" => {
      color: "blue" # default
    },
    "presupposition" => { 
      style: "dashed",
      color: "forestgreen"
    },
    "support" => {
      color: "forestgreen"
    },
    "external-obj" => {
      color: "orange"
    },
    "internal-obj" => {
      color: "red"
    },
    "counter" => {
      color: "green"
    },
    "note" => {
      style: "dotted"
    },
    "example" => {
      style: "dashed",
      color: "blue"
    },
    "type" => {
      color: "blue"
    },
    "question" => {
      color: "blue"
    }
  }

  NODE_KEYS = {
    "default" => {
      color: "blue",
      shape: "rectangle, style = rounded, penwidth = 3"
    },
    "roundrect" => {
      shape: "rectangle, style = rounded, penwidth = 3" # default
    },
    "blue" => {
      color: "blue" # default
    },
    "title" => { # head of branch
      shape: "tripleoctagon"
    },
    "level1" => {
      shape: "doubleoctagon"
    },
    "level2" => {
      shape: "octagon"
    },
    "level3" => {
      shape: "rectangle" # for indiv philosophers
    },
    "presupposition" => {
      color: "forestgreen",
      style: "dashed"
    },
    "support" => {
      color: "forestgreen"
    },
    "external-obj" => {
      color: "orange"
    },
    "internal-obj" => {
      color: "red"
    },
    "counter" => {
      color: "green"
    },
    "note" => {
      style: "dotted"
    },
    "example" => {
      style: "dashed"
    },
    "argument" => {
      color: "" # this needs more notation [this is to give it the colspan/rows format]
    }, 
    "types" => {
      color: "" # this needs more notation [this is to give it the rowspan/columns format]
    }
  }

  TABLE_KEYWORDS = {
    "<TABLE" => "[label=<<TABLE ALIGN=\"LEFT\" BORDER=\"#{TABLE_BORDER_THICKNESS}\" CELLBORDER=\"1\" CELLSPACING=\"0\" CELLPADDING=\"4\" STYLE=\"ROUNDED\"",
    "</TABLE>" => "</TABLE>>, shape = plaintext]",
    "==+" => "</TR>",
    "+==" => "<TR>",# each *real* row
    "+-----" => "<TD ROWSPAN=\"5\" ",
    "-----+" => "</TD>",# column spanning 5 rows
    "+----" => "<TD ROWSPAN=\"4\" ",
    "----+" => "</TD>",# column spanning 4 rows
    "+---" => "<TD ROWSPAN=\"3\" ",
    "---+" => "</TD>",# column spanning 3 rows
    "+--" => "<TD ROWSPAN=\"2\" ",
    "--+" => "</TD>",# column spanning 2 rows
    "+|||||" => "<TD COLSPAN=\"5\" ",
    "|||||+" => "</TD>",# row spanning 5 columns
    "+||||" => "<TD COLSPAN=\"4\" ",
    "||||+" => "</TD>",# row spanning 4 columns    
    "+|||" => "<TD COLSPAN=\"3\" ",
    "|||+" => "</TD>",# row spanning 3 columns
    "+||" => "<TD COLSPAN=\"2\" ",
    "||+" => "</TD>",# row spanning 2 columns
    "+-" => "<TD",
    "-+" => "</TD>"# column spanning 1 row (and vice versa!)
  }
end
