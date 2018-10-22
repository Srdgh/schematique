#!/usr/bin/env ruby

# TODO: have some presets (e.g. objection = red arrow in, green out; arguments displayed as Mrecord.)
# TODO: Read from JSON into various variables.
# NOTE: parsing is easier if HTML-like labels are in quotation marks than angle-brackets. I haven't seen a downside yet.

# format: 
# for node: node_name [label = "Lots of nice text." {default}]
# for edge: node1 -> node2 {{default}}

=begin
TODO: still to deal with: 
TODO: - slashes
TODO: -- round-rects = arguments or objections. can be all in one cell, or include multiple cells.
TODO: -- green arrow/box = supporting argument (points to upshot)
TODO: -- colspan then several columns in next row = types/varieties etc.
TODO: -- rowspan then several rows in next col = steps in an argument

TODO: not just colour and shape of box. Automatically do the colspan/rowspan thing based on whether the curly-bracket label says {types} or {argument}.
TODO: get the border thing right. (especially work out what's going wrong with deleting "R")
=end

# Usage: ./philosophy_flowcharter.rb ~/file.gv

require "./flowchart_keyword_list"
require "./diacritic_correction"
require # TODO: fill this in

# CONSTANTS

# Configure border thickness in the flowchart_keyword_list.

LINE_LENGTH = 40 # need different versions of this for the different parts of tables
TABLE_LINE_BASE = 25

COLUMN_COUNTER = {
  "+|||||" => 5,
  "+||||" => 4,
  "+|||" => 3,
  "+||" => 2,
  "+-" => 1
}

SVG_TEMP_FILES = [ ".svg" ]

TEMP_FILE = "#{Dir.home}/temp-phil-graphviz.gv"

# CLASSES

class Table
  @@tables = []

  attr_accessor :table

  def initialize
    @table = [] # create table array
    @@tables << self
  end

  def add_line_to_table(line) # add line to table (array of lines)
    @table << line.strip
  end

  def table_complete?
     @table.last.include?("</TABLE>")
  end

  def table_number_of_rows
     @table.count("+==") + table.count("==++==")
  end

  def table_current_row(cell_index)
     @table.count("+==") + @table[0..cell_index].count("==++==")
  end
  
  def table_number_of_columns
    @array_of_column_totals_for_each_row = []
    @current_row = 0
    @table.each {|line|
      if line.include?("+==")
        @current_row +=1
        @array_of_column_totals_for_each_row[@current_row] = 0
      end
      COLUMN_COUNTER.each_pair { |key, value| 
        if line.include?(key) then @array_of_column_totals_for_each_row[@current_row] +=value end # culumative within a row.
      }
    }
    @array_of_column_totals_for_each_row.delete_at(0) # zero-th row has nil columns
    @array_of_column_totals_for_each_row.sort.last # this gives the highest number of rows
  end

  def table_current_column(cell_index)
    @current_row = 0
    @iterator = 0
    while @current_row < table_current_row(cell_index) do
      @table[@iterator].include?("+==") && @current_row +=1
      @iterator +=1
    end
    @row_start_index = @iterator - 1
    @cell_row_columns = 0 # how many columns there are in the row this cell is in, to the left of the cell.
    @previous_cell_index = cell_index - 1
    @table[@row_start_index..@previous_cell_index].each {|line| 
      if line.include?("+==") # TODO: do I want this to be a separate if from the subsequent elsifs?
        @cell_row_columns = 0
      else
        COLUMN_COUNTER.each_pair { |key, value| 
          if line.include?(key) then @cell_row_columns +=value end 
        }
      end
    }
    @cell_row_columns # need another bit to this for cells which are first column in row, but span three columns, so appear to my formula as though they are in third column. (this currently should work for R, but not yet even trying to work for that specific case of L)
  end

  def top_and_bottom_border_control(cell_index) # cut top (right-angled) border for top cell (and same for bottom)
    if table_current_row(cell_index) == 1 then @sides.delete!("T") end
    if table_current_row(cell_index) == table_number_of_rows then @sides.delete!("B") end
  end # NB: for both these functions, can't have a case statement because might be both first and last row.

  def left_and_right_border_control(cell_index) #cut left (right-angled) border for left cell (and same for right)
    if table_current_column(cell_index) == 1 then @sides.delete!("L") end
    if table_current_column(cell_index) == (table_number_of_columns - 1) then @sides.delete!("R") end
  end

  def make_table # re-writes lines so they can be added to .gv file
    @table.each_index { |cell_index| # insert something here to filter out lines which are not cells.
      @sides = "TRLB"
      if @table[cell_index].match(/\+[\-\|]+/) # TODO: DOCUMENT THIS
        top_and_bottom_border_control(cell_index)
        left_and_right_border_control(cell_index)
        unless @sides == "TRLB" then @table[cell_index].sub!(/\+([\-\|]*)/, "+\\1 SIDES=\"#{@sides}\"") && puts("cell_index: Sides is now #{@sides}") end
      end
    }
    @table.each {|line|
      FlowchartKeywords::TABLE_KEYWORDS.select { |key| line.include?("#{key}") }.each { |key, value| line.sub!("#{key}", "#{value}") }
    }
    @table
  end
end

# METHODS

def tidy_up!(label)
  label.gsub!(/\s+/, " ") # tidy up: condense multiple spaces
  #label.gsub!(" \\n ", "\\n") # tidy up: condense multiple spaces 
  label.gsub!(" <BR/> ", "<BR/>") # tidy up: condense multiple spaces 
  label.gsub!("' s ", "'s ") # tidy up: rejoin posessives
  label.gsub!(/(\w\-)\s(\w)/, '\1\2') # tidy up: hyphens
  label.gsub!(/(\w)\s\'\s(\w)/, '\1 \'\2') # tidy up: opening quotation marks
  label.gsub!(/\<\s(\w+)\>/, '<\1>') # Quickfix: weird spaces (hope to eliminate)
  label.gsub!("</ I>", "</I>") # Quickfix: more weird spaces
  label.gsub!("</ B>", "</B>") # Quickfix: more weird spaces
  label.gsub!("< BR/>", "<BR/>") # Quickfix: more weird spaces
  label.gsub!("</<BR/>I>", "</I><BR/>") # Quickfix: more annoying things
  label.gsub!("</<BR/>B>", "</B><BR/>") # Quickfix: more annoying things
  label.gsub!("<<BR/>", "<BR/><") # Quickfix: angle-bracket clash
end

=begin
 Explain REGEX below
 \W? = maybe a non-word letter.
 [a-zA-Z0-9_\<\>\/]+ = one or more alphanumeric-or-underscore/anglebracket/forwardslash characters.
 \W = one non-word letter. Note this means the array includes spaces and punctuation.
 [^\s\w\(] = zero or more characters which are not spaces/letters/opening-bracket. This is to capture words followed by several non-word chars (e.g. full-stop then close quotation mark), without capturing the opening bracket of a following word.
 NB: The following exceptions are not captured: (1) one-word labels (2) the last word of a label which ends without fullstop/bracket etc.
=end

def add_line_breaks(label, line_length)
  number_of_letters = label.scan(/[a-zA-Z0-9_\<\>\/\s\(\)]/).size
  $desired_number_of_lines = (number_of_letters/line_length + 1) # For fewer than LINE_LENGTH letters, produce one line, etc.  
  @label_words_array = label.scan(/\W?[a-zA-Z0-9_\<\>\/]+\W[^\s\w\(]*/) # array of the label's words.
  if label.match(/\w$/) # Deal with above exceptions: if last char in label is a letter, add it to @label_words_array
    @label_words_array << label.scan(/\w+/).last
  end
  $current_word = 0
  $current_number_of_lines = 1
  $reset = false
  while $current_number_of_lines < $desired_number_of_lines do
    $current_line_length = 0
    while $current_line_length < line_length do
      if @label_words_array[$current_word]
        if @label_words_array[$current_word].include?("<BR/>") # if this is already formatted (e.g. if title)
          puts "break detected: #{@label_words_array[$current_word-1]}#{@label_words_array[$current_word]}"
          $current_line_length = line_length
          number_of_letters_left = @label_words_array[$current_word..-1].join.size
          $desired_number_of_lines = (number_of_letters_left/line_length + 1) + $current_number_of_lines + 1
          $reset = true
        else
          $current_line_length += @label_words_array[$current_word].size
        end
        $current_word +=1
      else
        $current_line_length = line_length # this is a bit dodgy.
      end
    end
    unless $reset
      @label_words_array = @label_words_array.insert($current_word, "<BR/>")
      $current_word +=1
    end
    $reset = false
    $current_number_of_lines +=1
  end
  label = @label_words_array * " " # Do I need this? already have spaces in @label_words_array, and in next line I delete double-spaces...
  tidy_up!(label)
  label
end

def add_edge_formatting!(line) # {{key}}
  FlowchartKeywords::EDGE_KEYS.select { |key| line.match("\{\{#{key}\}\}") }.each {|key, value|
    line.sub!("\{\{#{key}\}\}", "[color = #{value.fetch(:color, "blue")}, style = #{value.fetch(:style, "solid")}]")
  }
end

def add_node_formatting!(line) # {key}
  FlowchartKeywords::NODE_KEYS.select { |key| line.match(" \{#{key}\}") }.each {|key, value|
    line.sub!(" \{#{key}\}", ", color = #{value.fetch(:color, "blue")}, shape = #{value.fetch(:shape, "rectangle, style = rounded, penwidth = 3")}, style = #{value.fetch(:borderstyle, "solid")}")
  }
end

def do_titles(label) # this is at the end because otherwise rogue linebreaks might break it up. (maybe no more needed)
  label.gsub("<FOREIGN>", "<I>").gsub("</FOREIGN>", "</I>").gsub("<TITLE>", "<B>").gsub("</TITLE>", "</B><BR/><BR/>")
end

def deal_with_tables(original_lines, tabled_lines)
  table = false
  original_lines.each { |line|
    if line.include?("<TABLE") # start new table object
      @current_table = Table.new
      table = true
      verbose("New table")
    end
    if table # if currently in table object,
      if line.match(/\+[\-\|]+[^\>]*\>[^\+]+\+/) ## Something is going wrong here.
        table_line_raw = line.match(/\+([\-\|]+)[^\>]*\>([^\+]+)\+/) { |match| match[2].delete_suffix(match[1]).to_s }
        col_span = line.match(/\+([\-\|]+)[^\>]*\>([^\+]+)\+/) { |match| match[1].count("|") }
        col_span = col_span.eql?(0) ? 1 : col_span
        table_line_with_titles = do_titles(table_line_raw)
        table_line_with_breaks = add_line_breaks(table_line_with_titles, TABLE_LINE_BASE*col_span)
        line = line.gsub(/\+([\-\|]+)([^\>]*)\>([^\+]+)\+/, '+\1\2>LALALALALA\1+').gsub("LALALALALA", "#{table_line_with_breaks}") # is there a way to do this without this kludge?
      end ## TODO: if I start with the column counting and then do the break-insertion, I can make the tables look a lot nicer.
      @current_table.add_line_to_table(line) # add each new line to it
      if line.include?("</TABLE>") # if in table object and get end-table sign,
        @current_table.make_table.each {|line| tabled_lines << line } # add everything up and add to the "tabled_lines" array
        table = false # then end table object
      end
    else
      tabled_lines << line # if not in table, add line to "lines" array
    end
  }
end

def deal_with_formatting(tabled_lines, formatted_lines)
  tabled_lines.each { |line|
    label_raw = line.match(/label \= \"(.*)\"/) {|match| match[1].to_s } || "" # matches the label string (without quotation marks)
    label_with_titles = do_titles(label_raw) #maybe duplicated task given this is done with tables. work out where is best.
    label_with_breaks = add_line_breaks(label_with_titles, LINE_LENGTH)
    line.sub!(/label \= \".*\"/, "label = \<#{label_with_breaks}\>")
    add_edge_formatting!(line)
    add_node_formatting!(line)
    formatted_lines << line
  }
end

def write_to_temp_file(formatted_lines)
  File.open(TEMP_FILE, 'w') do |file| 
    formatted_lines.each { |line| file.puts(line) }
  end
end

def verbose(message)
  #if verbose
    puts "#{message}" # I can add a verbosity option later
  #end
end

def correct_diacritics(formatted_lines)
  DiacriticCorrection::DIACRITICS.each_pair { |wrong, right|
    formatted_lines.each { |line| line.gsub!(wrong, right) }
  }
end

# MAIN

process_file_name(".gv")

original_lines = []
IO.readlines(@source_file).each { |line| original_lines << line}

tabled_lines = []
deal_with_tables(original_lines, tabled_lines) && verbose("Tables done! #{tabled_lines.size} lines")

formatted_lines = []
deal_with_formatting(tabled_lines, formatted_lines) && verbose("Formatting done!!")

correct_diacritics(formatted_lines) && verbose("Diacritic-correction done!!")

write_to_temp_file(formatted_lines) && verbose("Written to temp file: #{TEMP_FILE}")

convert_GV_to_PDF(@target_arr[0..1].join, @target_arr[2]) && verbose("converted #{@target_arr[0..1].join}#{@target_arr[2]}")

@one_drive && move_files_back_to_original_directory && verbose("Done the OneDrive thing") # delete when freed from OneDrive

trash_intermediary_files(SVG_TEMP_FILES) && verbose("trashed SVG temp files")
