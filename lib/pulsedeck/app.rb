module Pulsedeck
  class App < Sinatra::Base
    get "/" do
      content_type "text/html"
      Views::TestPage.new.call
    end
  end
end
