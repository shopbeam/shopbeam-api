shared_examples_for '#phone_number' do
  it 'is an alias of #phoneNumber' do
    payment = described_class.new(phoneNumber: '123-456-7890')

    expect(payment.phone_number).to eq('123-456-7890')
  end
end
