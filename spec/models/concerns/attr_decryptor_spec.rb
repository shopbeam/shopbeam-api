require 'rails_helper'

describe AttrDecryptor do
  class Model
    include AttrDecryptor

    def read_attribute(*); end
  end

  context 'for a single attribute' do
    context 'when type is not specified' do
      it 'returns decrypted value as string' do
        class Model
          attr_decryptor :foo
        end

        model = Model.new
        encrypted = Encryptor.encrypt('1')

        expect(model).to receive(:read_attribute).with(:foo).and_return(encrypted[:value])
        expect(model).to receive(:read_attribute).with(:foo_salt).and_return(encrypted[:salt])

        expect(model.foo).to eq('1')
      end

      it 'accepts custom salt attribute' do
        class Model
          attr_decryptor :foo, salt: :salt_attr
        end

        model = Model.new
        encrypted = Encryptor.encrypt('bar')

        expect(model).to receive(:read_attribute).with(:foo).and_return(encrypted[:value])
        expect(model).to receive(:read_attribute).with(:salt_attr).and_return(encrypted[:salt])

        expect(model.foo).to eq('bar')
      end
    end

    context 'when type is specified' do
      shared_examples 'returns decrypted value' do |type, result|
        input, output = result.first

        it "as #{type}" do
          model = klass.new
          encrypted = Encryptor.encrypt(input)

          expect(model).to receive(:read_attribute).with(:foo).and_return(encrypted[:value])
          expect(model).to receive(:read_attribute).with(:foo_salt).and_return(encrypted[:salt])

          expect(model.foo).to eq(output)
        end
      end

      %i(string text).each do |type|
        it_behaves_like 'returns decrypted value', type, 'bar' => 'bar' do
          let(:klass) do
            Class.new(Model) do
              attr_decryptor :foo, type: type
            end
          end
        end
      end

      it_behaves_like 'returns decrypted value', :integer, '1' => 1 do
        let(:klass) do
          Class.new(Model) do
            attr_decryptor :foo, type: :integer
          end
        end
      end

      %i(float decimal).each do |type|
        it_behaves_like 'returns decrypted value', type, '1.23' => 1.23 do
          let(:klass) do
            Class.new(Model) do
              attr_decryptor :foo, type: type
            end
          end
        end
      end

      it_behaves_like 'returns decrypted value', :boolean, 'true' => true do
        let(:klass) do
          Class.new(Model) do
            attr_decryptor :foo, type: :boolean
          end
        end
      end

      it 'accepts custom salt attribute' do
        class Model
          attr_decryptor :foo, type: :integer, salt: :salt_attr
        end

        model = Model.new
        encrypted = Encryptor.encrypt('1')

        expect(model).to receive(:read_attribute).with(:foo).and_return(encrypted[:value])
        expect(model).to receive(:read_attribute).with(:salt_attr).and_return(encrypted[:salt])

        expect(model.foo).to eq(1)
      end
    end

    it 'returns nil for nil' do
      class Model
        attr_decryptor :foo
      end

      model = Model.new

      expect(model).to receive(:read_attribute).with(:foo).and_return(nil)

      expect(model.foo).to eq(nil)
    end

    it 'returns nil for empty string' do
      class Model
        attr_decryptor :foo
      end

      model = Model.new

      expect(model).to receive(:read_attribute).with(:foo).and_return('')

      expect(model.foo).to eq(nil)
    end
  end

  context 'for multiple attributes' do
    context 'when type is not specified' do
      it 'returns decrypted values as strings' do
        class Model
          attr_decryptor :foo, :bar, :baz, :qux
        end

        model = Model.new
        encrypted_one = Encryptor.encrypt('1')
        encrypted_two = Encryptor.encrypt('2')

        expect(model).to receive(:read_attribute).with(:foo).and_return(encrypted_one[:value])
        expect(model).to receive(:read_attribute).with(:foo_salt).and_return(encrypted_one[:salt])
        expect(model).to receive(:read_attribute).with(:bar).and_return(encrypted_two[:value])
        expect(model).to receive(:read_attribute).with(:bar_salt).and_return(encrypted_two[:salt])
        expect(model).to receive(:read_attribute).with(:baz).and_return(nil)
        expect(model).to receive(:read_attribute).with(:qux).and_return('')

        expect(model.foo).to eq('1')
        expect(model.bar).to eq('2')
        expect(model.baz).to eq(nil)
        expect(model.qux).to eq(nil)
      end

      it 'accepts custom salt attribute being common for all values' do
        class Model
          attr_decryptor :foo, :bar, salt: :salt_attr
        end

        model = Model.new
        salt = SecureRandom.base64
        encrypted_one = Encryptor.encrypt('1', salt)
        encrypted_two = Encryptor.encrypt('2', salt)

        expect(model).to receive(:read_attribute).with(:foo).and_return(encrypted_one[:value])
        expect(model).to receive(:read_attribute).with(:bar).and_return(encrypted_two[:value])
        allow(model).to receive(:read_attribute).with(:salt_attr).and_return(salt)

        expect(model.foo).to eq('1')
        expect(model.bar).to eq('2')
      end
    end

    context 'when type is specified' do
      it 'returns decrypted values of target type' do
        class Model
          attr_decryptor :foo, :bar, :baz, :qux, type: :integer
        end

        model = Model.new
        encrypted_one = Encryptor.encrypt('1')
        encrypted_two = Encryptor.encrypt('2')

        expect(model).to receive(:read_attribute).with(:foo).and_return(encrypted_one[:value])
        expect(model).to receive(:read_attribute).with(:foo_salt).and_return(encrypted_one[:salt])
        expect(model).to receive(:read_attribute).with(:bar).and_return(encrypted_two[:value])
        expect(model).to receive(:read_attribute).with(:bar_salt).and_return(encrypted_two[:salt])
        expect(model).to receive(:read_attribute).with(:baz).and_return(nil)
        expect(model).to receive(:read_attribute).with(:qux).and_return('')

        expect(model.foo).to eq(1)
        expect(model.bar).to eq(2)
        expect(model.baz).to eq(nil)
        expect(model.qux).to eq(nil)
      end

      it 'accepts custom salt attribute being common for all values' do
        class Model
          attr_decryptor :foo, :bar, type: :integer, salt: :salt_attr
        end

        model = Model.new
        salt = SecureRandom.base64
        encrypted_one = Encryptor.encrypt('1', salt)
        encrypted_two = Encryptor.encrypt('2', salt)

        expect(model).to receive(:read_attribute).with(:foo).and_return(encrypted_one[:value])
        expect(model).to receive(:read_attribute).with(:bar).and_return(encrypted_two[:value])
        allow(model).to receive(:read_attribute).with(:salt_attr).and_return(salt)

        expect(model.foo).to eq(1)
        expect(model.bar).to eq(2)
      end
    end
  end
end
