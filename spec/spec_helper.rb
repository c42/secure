require 'secure'

def except_on_OSX
  pending "does not work on OSX" if RUBY_PLATFORM =~ /darwin/
end
