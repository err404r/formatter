RSpec.describe "a group with no user-defined metadata" do
  it 'has an data with metadata', :foo => 17 do |data|
    expect(data.metadata[:foo]).to eq(17)
    expect(data.metadata).not_to include(:bar)
  end

  it 'has another data with metadata', :bar => 12, :bazz => 33 do |data|
    expect(data.metadata[:bar]).to eq(12)
    expect(data.metadata[:bazz]).to eq(33)
    expect(data.metadata).not_to include(:foo)
  end
end

RSpec.describe "a group with user-defined metadata", :foo => 'bar' do
  it 'can be overridden by an example', :foo => 'bazz' do |example|
    expect(example.metadata[:foo]).to eq('bazz')
  end

  context "with overrided metadata", :foo => 'goo' do
    it 'can be overridden by a sub-group' do |example|
      expect(example.metadata[:foo]).to eq('goo')
    end
  end
end
