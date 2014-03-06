require 'test_helper'

class MyModel
  include MLSGem::Model

end

class TestModel < ::Test::Unit::TestCase

  def test_instance_methods
    model = MyModel.new

    assert model.respond_to?(:attribute)
    assert model.respond_to?(:attributes)
    assert model.respond_to?(:attribute_module)
    assert model.respond_to?(:create_reader_for)
    assert model.respond_to?(:create_writer_for)
    assert model.respond_to?(:model_name)
    assert model.respond_to?(:param_key)
    assert model.respond_to?(:root_element)
    assert model.respond_to?(:collection_root_element)
  end

end
