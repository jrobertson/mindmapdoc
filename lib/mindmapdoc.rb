#!/usr/bin/env ruby

# file: mindmapdoc.rb

require 'rdiscount'
require 'mindmapviz'


class MindmapDoc

  attr_accessor :root

  def initialize(s=nil, root: 'root', debug: false)

    @root, @tree, @txtdoc, @svg, @debug = root, '', '', '', debug
    import(s) if s
    
  end
  
  def import(raw_s)
    
    s = raw_s.strip
    
    if s =~ /^#+ / then
      @txtdoc = s.gsub(/\r/,'')
      @tree, @html = parse_doc s
    else
      @tree, @txtdoc = parse_tree s
    end

    @svg = build_svg(@tree)    
    
  end
  
  def load(s='mindmap.md')
    buffer = File.read(s)
    import(buffer)
  end

  def to_html()
    @html
  end
  
  def to_svg()
    @svg
  end   

  def to_tree(rooted: false)
    lines = @tree.lines
    lines.shift    
    r = lines.map! {|x| x[2..-1]}.join
    @root + "\n" + r.lines.map {|x| '  ' + x}.join if rooted
  end
  
  alias to_s to_tree

  def to_md()
    @txtdoc
  end

  alias to_doc to_md
  
  def save(s='mindmap.md')
    File.write s, @txtdoc
    'mindmap written to file'
  end

  private
  
  def build_svg(s)
    
    src = s.lines.map {|x| "%s # #%s" % [x.chomp, x.downcase.gsub(/\s/,'')]}\
            .join("\n")
    
    mmv = Mindmapviz.new src, fields: %w(label url), delimiter: ' # ' 
    mmv.to_svg.sub(/.*(?=\<svg)/m,'')
    
  end
  
  # returns a indented string representation of the mindmap and HTML from 
  # the rendered Markdown
  #
  def parse_doc(md)
    
    puts 'inside parse_doc: ' + md if @debug

    s = RDiscount.new(md.gsub(/\r/,'')).to_html.gsub(/(?<=\<h)[^\<]+/) do |x| 
      id = x[/(?<=\>).*/].downcase.gsub(/\s/,'')
      "#{ x[/\d/]} id='#{id}'>#{x[/(?<=\>).*/]}"
    end
    
    lines = md.scan(/#[^\n]+\n/)\
        .map {|x| ('  ' * (x.scan(/#/).length - 1)) + x[/(?<=# ).*/]}
    @root = lines.first

    [lines.join("\n"), s]
  end


  # returns a markdown document
  #
  def parse_tree(s)

#     asrc = [@root + "\n"] + s.gsub(/\r/,'').strip.lines.map {|x| '  ' + x}

    a2 = asrc.inject([]) do |r,x| 

      if x.strip.length > 0 then
        r << '#' * (x.scan(/ {2}/).length + 1) + ' ' + x.lstrip
      else
        r
      end

    end
    
    a = @txtdoc.split(/.*(?=\n#)/).map(&:strip)

    a3 = []

    a2.each do |x|

      r = a.grep /#{x}/
      r2 = r.any? ? r.first : x
      a3 << "\n" + r2.strip.sub(/\w/) {|x| x.upcase} + "\n"

    end
    
    [asrc.join, a3.join]

  end

end
