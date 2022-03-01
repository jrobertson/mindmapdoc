#!/usr/bin/env ruby

# file: mindmapdoc.rb


require 'c32'
require 'kramdown'
require 'mindmapviz'
require 'rxfreadwrite'


class MindmapDoc
  using ColouredText
  include RXFReadWriteModule

  attr_accessor :root

  def initialize(s=nil, root: nil, debug: false)

    @root, @tree, @txtdoc, @svg, @debug = root, '', '', '', debug
    puts '@root' + @root.inspect if @debug
    import(s) if s
    
  end
  
  def import(raw_s)
    
    s = raw_s.lstrip
    
    if s =~ /^#+ / then
      @txtdoc = s.gsub(/\r/,'')
      @tree, @html = parse_doc s
    else
      @tree, @txtdoc = parse_tree s
    end

    puts ('@tree: ' + @tree.inspect).debug if @debug
    @svg = build_svg(to_tree(rooted: true))
    
  end
  
  def load(s='mindmap.md')
    buffer = FileX.read(s)
    import(buffer)
  end
  
  # parses a string containing 1 or more embedded <mindmap> elements and 
  # outputs the SVG and associated doc
  #
  def transform(s)
    
    data = []
    a = s.split(/(?=^<mindmap[^>]*>)/)
    puts ('transform: a: ' + a.inspect).debug if @debug
    return s unless a.length > 1
    
    count = 0
    
    a2 = a.map do |x|

      if x =~ /^<mindmap/ then
        
        count += 1
        
        mm, remaining = x[/<mindmap[^>]*>(.*)/m,1].split(/<\/mindmap>/,2)
        
        if @debug then
          puts ('mm: ' + mm.inspect + 
          ' remaining: ' + remaining.inspect).debug
        end
        
        raw_tree, raw_md = mm.split(/-{10,}/,2)
        
        
        if @debug then
          puts ('raw_md: ' + raw_md.inspect +
          ' raw_tree: ' + raw_tree.inspect + 
          ' raw_md: ' + raw_md.inspect).debug
        end
        
        mm1 = MindmapDoc.new raw_tree, debug: @debug

        if raw_md then
          mm2 = MindmapDoc.new raw_md, debug: @debug
          data << mm2.to_mmv(id: count)
        end

        docwidth = x[/<mindmap +docwidth=['"]([^'"]+)/,1]
        
        
        if @debug then
          
          puts ('docwidth: ' + docwidth.inspect +
          ' mm1.to_svg: ' + mm1.to_svg.inspect +
          ' mm2.to_doc: '  + mm2.to_doc.inspect).debug
          
        end
                
        mm_template("!s[](#mindmap#{count})\n\n", mm2.to_doc, 
                    count, docwidth) + remaining
        
      else
        x
      end

    end

    if data.any? then
      a2.join + "\n__DATA__\n\n" + data.join("\n")
    else
      s
    end
    
  end   
  
  def to_html()
    @html
  end
  
  # used for finding and parsing mindmapdoc blocks within a Markdown document
  # 
  def to_mindmapdoc(s)

    s2 = s.split(/(?=^--?mm-+)/).map do |raw_s|

      if raw_s =~ /^--?mm--/ then
        
        a2 = raw_s[/.*(?=^-{10,})/m].lines
        remaining = ($').lines[1..-1].join
        a2.shift
        content = a2.join
        rooted = content =~ /^# / ? true : false
        puts ('content: ' + content.inspect).debug if @debug
        tree = MindmapDoc.new(content, debug: @debug).to_tree(rooted: rooted)
        "<mindmap>\n%s\n\n----------\n\n%s</mindmap>\n\n%s" \
            % [tree, content, remaining]
        
      else
        raw_s
      end

    end.join()

  end
  
  alias to_mmd to_mindmapdoc
  
  def to_mindmapviz(id: '')
    
    lines = to_tree().lines.map do |raw_label|
      
      label = raw_label.chomp
      "%s # #%s" % [label, label.lstrip.downcase.gsub(' ', '-')]
    end
    
"<?mindmapviz root=\"#{root}\" fields='label, url' delimiter=' # ' " \
        + "id='mindmap#{id}'?>
    
#{lines.join("\n")}
"
    
  end
  
  alias to_mmv to_mindmapviz
  
  def to_svg()
    @svg
  end   

  def to_tree(rooted: false)
        
    if rooted then      
      @root.chomp + "\n" + @tree
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
    FileX.write s, @txtdoc
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

    puts ('docwidth: ' + docwidth.inspect).debug if @debug
    
    style = "float: right; width: #{docwidth || '50%'}; \
overflow-y: auto; height: 70vh; "
    puts ('style: ' + style.inspect).debug if @debug
"<div id='mindmap#{count}'>
#{svg}
<div markdown='1' style='#{style}'>
#{doc}
</div>
</div>
<div style='clear:both'/>
"
  end
  
  
  # returns a indented string representation of the mindmap and HTML from 
  # the rendered Markdown
  #
  def parse_doc(md)
    
    puts ('inside parse_doc: ' + md).debug if @debug

    s = Kramdown::Document.new(md.gsub(/\r/,'')
                               .gsub(/\b'\b/,"{::nomarkdown}'{:/}")).to_html
    
    lines = md.scan(/#[^\n]+\n/)\
        .map {|x| ('  ' * (x.scan(/#/).length - 1)) + x[/(?<=# ).*/].lstrip}

    if @root.nil? then
      @root = if lines.first[/^[^#\s]/] then
        lines.shift.chomp
      else
        'root'
      end
    end
    
    puts ('lines: ' + lines.inspect).debug if @debug
    [lines.join("\n"), s]
  end
  

  # returns a markdown document
  #
  def parse_tree(s)

    puts ('inside parse_tree').info if @debug
    
    lines = s.gsub(/\r/,'').strip.lines

    if @root.nil? and s[/^\w[^\n]+\n\n/] then
      @root = lines.shift
      lines.shift
    end


    if @root.nil? and lines.grep(/^\w/).length == 1 then
      @root = lines.shift
      lines.map! {|x| x[2..-1]}
    end 

    puts ('lines: ' + lines.inspect) if @debug
    
    puts ('@root:'  + @root.inspect).debug if @debug
  
    asrc = lines.map {|x| '  ' + x}

    a2 = asrc.inject([]) do |r,x| 

      if x.strip.length > 0 then
        r << '#' * (x.scan(/ {2}/).length + 1) + ' ' + x.lstrip
      else
        r
      end

    end

    a2.unshift('# ' + @root + "\n") if @root 
    
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
