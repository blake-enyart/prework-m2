require 'rack'

class PersonalSite

  def self.call(env)
    case env["PATH_INFO"]
    when '/' then index
    else
       error
    end
  end

  def self.index
    render_view('index.html')
  end

  def self.error
    render_view('error.html', '404')
  end

  def self.css
    render_static('main.css')
  end

  def self.render_view(page, code = '200')
    [code, {'Content-Type' => 'text/html'}, [File.read("./app/views/#{page}")]]
  end

  def self.render_static(asset)
    [200, {'Content-Type' => 'text/html'}, [File.read("./stylesheets/#{asset}")]]
  end
end
