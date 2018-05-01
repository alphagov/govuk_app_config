RSpec.shared_examples "a healthcheck" do |healthcheck|
  it "has a name" do
    expect(healthcheck).to respond_to(:name)
    expect(healthcheck.name).to be_a(Symbol)
  end

  it "returns a valid status" do
    expect(healthcheck).to respond_to(:status)
    expect(GovukHealthcheck::STATUSES).to include(healthcheck.status)
  end

  it "optionally returns a `details` hash with no reserved keys" do
    if healthcheck.respond_to?(:details)
      expect(healthcheck.details).to be_a(Hash)
      expect(healthcheck.details).not_to have_key(:status)
    end
  end
end
