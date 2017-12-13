#!/usr/bin/env ruby

# file: mindmapdoc.rb

require 'rdiscount'
require 'mindmapviz'


class MindmapDoc

  attr_accessor :root

  def initialize(s=nil, root: 'root')

    @root, @tree, @txtdoc, @svg = root, '', '', ''
    import(s) if s
    
  end
  
  def import(s)
    
    if s =~ /^# / then
      @txtdoc = s.gsub(/\r/,'')
      @tree, @html = parse_doc s
    else
      @tree, @txtdoc = parse_tree s
    end

    @svg = build_svg(@tree)    
    
  end

  def to_svg()
    @svg
  end

  def to_tree()
    @tree
  end

  def to_md()
    @txtdoc
  end

  alias to_doc to_md

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

    s = RDiscount.new(md.gsub(/\r/,'')).to_html.gsub(/(?<=\<h)[^\<]+/) do |x| 
      id = x[/(?<=\>).*/].downcase.gsub(/\s/,'')
      "#{ x[/\d/]} id='#{id}'>#{x[/(?<=\>).*/]}"
    end
    
    linex = md.scan(/#[^\n]+\n/).map {|x| ('  ' * (x.scan(/#/).length - 1)) + x[/(?<=# ).*/]}
    #log.info 'mindmap: linex: ' + linex.inspect
    @root = linex.shift
    linex.map! {|x| x[2..-1]}
    #log.info 'mindmap: root: ' + @root.inspect
    txt = linex.join("\n")
    
    #log.info 'mindmap: txt: ' + txt.inspect

    [txt, s]
  end


  # returns a markdown document
  #
  def parse_tree(s)

    asrc = [@root] + s.gsub(/\r/,'').strip.lines.map {|x| '  ' + x}

    a2 = asrc.inject([]) do |r,x| 

      if x.strip.length > 0 then
        r << '#' * (x.scan(/ {2}/).length + 1) + ' ' + x.lstrip
      else
        r
      end

    end
    
    #log.info 'mindmap: a2' + a2.inspect
    a = @txtdoc.split(/.*(?=\n#)/).map(&:strip)

    a3 = []

    a2.each do |x|

      r = a.grep /#{x}/
      #log.info 'mindmap: ' + r.inspect
      r2 = r.any? ? r.first : x
      a3 << "\n" + r2.strip.sub(/\w/) {|x| x.upcase} + "\n"

    end
    #log.info 'mindmap: a3:'  + a3.inspect
    
    [asrc.join, a3.join]

  end

end
