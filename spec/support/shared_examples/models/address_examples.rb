shared_examples 'delegates methods to user' do |methods|
  methods.each do |method|
    it { is_expected.to delegate_method(method).to(:user) }
  end
end
