# Introducing the mindmapdoc gem

    require 'logger'
    require 'mindmapdoc'

    s = "
    breakfast
      porridge
      coffee
    lunch
      pizza
    dinner
      cheese burgers
    "
    mmd = MindmapDoc.new(s, root: 'today')
    puts mmd.to_doc

## Markdown document output

<pre>
# Today

## Breakfast

### Porridge

### Coffee

## Lunch

### Pizza

## Dinner

### Cheese burgers
</pre>

    mmd.to_svg

## SVG Output

<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="325pt" height="272pt" viewBox="0.00 0.00 325.04 271.77">
<g id="graph0" class="graph" transform="scale(1 1) rotate(0) translate(157.755 148.349)">
<title>G</title>
<polygon fill="white" stroke="none" points="-157.755,123.421 -157.755,-148.349 167.287,-148.349 167.287,123.421 -157.755,123.421"></polygon>
<!-- today -->
<g id="node1" class="node"><title>today</title>
<ellipse fill="#ccffcc" stroke="#ddaa66" cx="-0.288183" cy="11.0909" rx="27" ry="18"></ellipse>
<text text-anchor="middle" x="-0.288183" y="12.9909" font-family="" font-size="8.00" fill="#330055">today</text>
</g>
<!-- breakfast -->
<g id="node2" class="node"><title>breakfast</title>
<ellipse fill="#ccffcc" stroke="#ddaa66" cx="-0.563912" cy="-71.4122" rx="27" ry="18"></ellipse>
<text text-anchor="middle" x="-0.563912" y="-69.5122" font-family="" font-size="8.00" fill="#330055">breakfast</text>
</g>
<!-- today&#45;&gt;breakfast -->
<g id="edge1" class="edge"><title>today-&gt;breakfast</title>
<path fill="none" stroke="#999999" d="M-0.349376,-7.21918C-0.395069,-20.8914 -0.457238,-39.4934 -0.50289,-53.1533"></path>
</g>
<!-- lunch -->
<g id="node3" class="node"><title>lunch</title>
<ellipse fill="#ccffcc" stroke="#ddaa66" cx="-66.5438" cy="56.6003" rx="27" ry="18"></ellipse>
<text text-anchor="middle" x="-66.5438" y="58.5003" font-family="" font-size="8.00" fill="#330055">lunch</text>
</g>
<!-- today&#45;&gt;lunch -->
<g id="edge2" class="edge"><title>today-&gt;lunch</title>
<path fill="none" stroke="#999999" d="M-19.0972,24.0104C-27.973,30.107 -38.547,37.37 -47.4577,43.4905"></path>
</g>
<!-- dinner -->
<g id="node4" class="node"><title>dinner</title>
<ellipse fill="#ccffcc" stroke="#ddaa66" cx="66.5876" cy="55.8158" rx="27" ry="18"></ellipse>
<text text-anchor="middle" x="66.5876" y="57.7158" font-family="" font-size="8.00" fill="#330055">dinner</text>
</g>
<!-- today&#45;&gt;dinner -->
<g id="edge3" class="edge"><title>today-&gt;dinner</title>
<path fill="none" stroke="#999999" d="M19.0551,24.0272C28.0047,30.0125 38.6033,37.1005 47.5188,43.063"></path>
</g>
<!-- porridge -->
<g id="node5" class="node"><title>porridge</title>
<ellipse fill="#ccffcc" stroke="#ddaa66" cx="57.0518" cy="-125.996" rx="27" ry="18"></ellipse>
<text text-anchor="middle" x="57.0518" y="-124.096" font-family="" font-size="8.00" fill="#330055">porridge</text>
</g>
<!-- breakfast&#45;&gt;porridge -->
<g id="edge4" class="edge"><title>breakfast-&gt;porridge</title>
<path fill="none" stroke="#999999" d="M15.1798,-86.3274C23.3095,-94.0292 33.2002,-103.399 41.3271,-111.099"></path>
</g>
<!-- coffee -->
<g id="node6" class="node"><title>coffee</title>
<ellipse fill="#ccffcc" stroke="#ddaa66" cx="-57.6615" cy="-126.349" rx="27" ry="18"></ellipse>
<text text-anchor="middle" x="-57.6615" y="-124.449" font-family="" font-size="8.00" fill="#330055">coffee</text>
</g>
<!-- breakfast&#45;&gt;coffee -->
<g id="edge5" class="edge"><title>breakfast-&gt;coffee</title>
<path fill="none" stroke="#999999" d="M-16.1661,-86.424C-24.2226,-94.1757 -34.0244,-103.607 -42.0782,-111.356"></path>
</g>
<!-- pizza -->
<g id="node7" class="node"><title>pizza</title>
<ellipse fill="#ccffcc" stroke="#ddaa66" cx="-126.755" cy="101.421" rx="27" ry="18"></ellipse>
<text text-anchor="middle" x="-126.755" y="103.321" font-family="" font-size="8.00" fill="#330055">pizza</text>
</g>
<!-- lunch&#45;&gt;pizza -->
<g id="edge6" class="edge"><title>lunch-&gt;pizza</title>
<path fill="none" stroke="#999999" d="M-84.609,70.0481C-92.2297,75.721 -101.083,82.3112 -108.702,87.983"></path>
</g>
<!-- cheese burgers -->
<g id="node8" class="node"><title>cheese burgers</title>
<ellipse fill="#ccffcc" stroke="#ddaa66" cx="128.172" cy="98.8288" rx="35.2305" ry="18"></ellipse>
<text text-anchor="middle" x="128.172" y="100.729" font-family="" font-size="8.00" fill="#330055">cheese burgers</text>
</g>
<!-- dinner&#45;&gt;cheese burgers -->
<g id="edge7" class="edge"><title>dinner-&gt;cheese burgers</title>
<path fill="none" stroke="#999999" d="M85.3997,68.9548C92.3328,73.7972 100.226,79.31 107.328,84.2703"></path>
</g>
</g>
</svg>


## Importing a markdown document

    s2 = "
    # Today

    ## Breakfast

    ### Porridge

    ### Coffee

    ## Lunch

    ### Pizza

    ## Dinner

    ### Cheese burgers
    "

    mmd = MindmapDoc.new(s2)
    mmd.root  #=> Today
    mmd.to_s

## Tree Output

<pre>
Breakfast
  Porridge
  Coffee
Lunch
  Pizza
Dinner
  Cheese burgers
</pre>

## Resources

* mindmapdoc https://rubygems.org/gems/mindmapdoc

mindmap mindmapdoc gem
