RSpec.describe Pulsedeck::App do
  def app = described_class

  describe "GET /" do
    before { get "/" }

    it "returns an HTML page" do
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include("text/html")
    end

    it "has the title and three panels" do
      body = last_response.body
      expect(body).to include("<title>Pulsedeck</title>")
      ["CPU temperature", "GPU power", "Fan speed"].each do |panel_title|
        expect(body).to include(panel_title)
      end
    end
  end

  it "returns 404 for an unknown path" do
    get "/nope"
    expect(last_response.status).to eq(404)
  end
end
