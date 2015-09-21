class KeywordStruct < Struct
  def initialize(**args)
    args.each { |key, value| self[key] = value }
  end
end
