module HtmlMockup
  class Cli::Serve < Cli::Command


    desc "Serve the current project"

    class_options :port => :string, # Defaults to 9000
                   :handler => :string, # The handler to use (defaults to mongrel)
                   :validate => :boolean # Run validation?

    def serve
      
      server_options = {} 
      options.each{|k,v| server_options[k.to_sym] = v }
      server_options[:server] = {}
      [:port, :handler, :validate].each do |k|
        server_options[:server][k] = server_options.delete(k) if server_options.has_key?(k)
      end
      
      server = @project.server
      server.set_options(server_options[:server])
      
      puts "Running HtmlMockup with #{server.handler.inspect} on port #{server.port}"
      puts project_banner(@project) 
      
      server.run!
    end
  end
end