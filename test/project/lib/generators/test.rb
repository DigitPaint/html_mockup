class TestGenerator < HtmlMockup::Generators::Base

  def do
    puts "Done!"
  end

end

HtmlMockup::Generators::Base.register TestGenerator