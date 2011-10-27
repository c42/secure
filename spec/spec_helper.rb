require 'secure'

def except_on_OSX_it(name)
  it name do
    pending "does not work on OSX" if RUBY_PLATFORM =~ /darwin/
    yield
  end
end
