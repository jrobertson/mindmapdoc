Gem::Specification.new do |s|
  s.name = 'mindmapdoc'
  s.version = '0.1.5'
  s.summary = 'Transforms a markdown document into a mindmap or a ' +
      ' mindmap into a markdown document'
  s.authors = ['James Robertson']
  s.files = Dir['lib/mindmapdoc.rb']
  s.add_runtime_dependency('rdiscount', '~> 2.2', '>=2.2.0.1')
  s.add_runtime_dependency('mindmapviz', '~> 0.2', '>=0.2.3')
  s.signing_key = '../privatekeys/mindmapdoc.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/mindmapdoc'
end
