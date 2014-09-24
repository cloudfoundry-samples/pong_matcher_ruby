module CollectionExamples
  def test_stores_symbols
    @coll << {foo: :bar}
    assert_equal :bar, @coll.detect { |item| item.has_key?(:foo) }[:foo]
  end
end
