Gem::Specification.new do |s|
  s.name = 'mindmapdoc'
  s.version = '0.3.1'
  s.summary = 'Transforms a markdown document into a mindmap or a ' +
      ' mindmap into a markdown document'
  s.authors = ['James Robertson']
  s.files = Dir['lib/mindmapdoc.rb']
  s.add_runtime_dependency('c32', '~> 0.1', '>=0.1.2')
  s.add_runtime_dependency('kramdown', '~> 1.17', '>=1.17.0')
  s.add_runtime_dependency('mindmapviz', '~> 0.2', '>=0.2.3')
  s.signing_key = '../privatekeys/mindmapdoc.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/mindmapdoc'
end
