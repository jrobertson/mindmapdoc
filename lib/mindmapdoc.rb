#!/usr/bin/env ruby

# file: mindmapdoc.rb


require 'kramdown'
require 'mindmapviz'



class MindmapDoc

  attr_accessor :root

  def initialize(s=nil, root: nil, debug: false)

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
  
  # parses a string containing 1 or more embedded <mindmap> elements and 
  # outputs the SVG and associated doc
  #
  def transform(s)
    
    a = s.split(/(?=^<mindmap[^>]*>)/)
    puts 'transform: a: ' + a.inspect if @debug
    
    count = 0
    
    a2 = a.map do |x|

      if x =~ /^<mindmap/ then
        
        count += 1
        
        mm, remaining = x[/<mindmap[^>]*>(.*)/m,1].split(/<\/mindmap>/,2)
        raw_tree, raw_md = mm.split(/-{10,}/,2)
        mm1, mm2 = [raw_tree, raw_md].map {|x| MindmapDoc.new x}
        docwidth = x[/<mindmap +docwidth=['"]([^'"]+)/,1]
        puts 'docwidth: ' + docwidth.inspect if @debug
        
        mm_template(mm1.to_svg, mm2.to_doc, count, docwidth) + remaining
        
      else
        x
      end

    end.join
    
  end    
  
  def to_html()
    @html
  end
  
  def to_svg()
    @svg
  end   

  def to_tree(rooted: false)
        
    if rooted then
      @root + "\n" + @tree
    else
      
      lines = @tree.lines      
      lines.shift  if lines.first[/^\S/]
      lines.map! {|x| x[2..-1]}.join
    end
    
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
  
  def build_svg(s, auto_url: true)
    
    src = s.lines.map do |x| 
      "%s # #%s" % [x.chomp, x.strip.downcase.gsub(/ +/,'-')]
    end.join("\n")
    
    mmv = Mindmapviz.new src, fields: %w(label url), delimiter: ' # ' 
    mmv.to_svg.sub(/.*(?=\<svg)/m,'')
    
  end
  
  # used by public method transform()
  #
  def mm_template(svg, doc, count, docwidth='50%')

    style = "float: right; width: #{docwidth || '50%'}; \
overflow-y: auto; height: 70vh; "
    
"<div id='mindmap#{count}'>
#{svg}
<div markdown='1' style='#{style}'>
#{doc}
</div>
</div>
"
  end
  
  
  # returns a indented string representation of the mindmap and HTML from 
  # the rendered Markdown
  #
  def parse_doc(md)
    
    puts 'inside parse_doc: ' + md if @debug

    s = Kramdown::Document.new(md.gsub(/\r/,'')).to_html
    
    lines = md.scan(/#[^\n]+\n/)\
        .map {|x| ('  ' * (x.scan(/#/).length - 1)) + x[/(?<=# ).*/]}
    @root = lines.first if lines.first[/^# /]

    [lines.join("\n"), s]
  end
  

  # returns a markdown document
  #
  def parse_tree(s)

    puts 'inside parse_tree' if @debug
    
    lines = s.gsub(/\r/,'').strip.lines
    
    @root = if lines.first[/^[^#\s]/] then
      lines.shift.chomp
    elsif @root.nil?
      'root'
    end
  
    asrc = [@root + "\n"] + lines.map {|x| '  ' + x}

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
