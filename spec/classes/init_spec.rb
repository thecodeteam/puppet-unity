require 'spec_helper'
describe 'unity' do
  context 'with default values for all parameters' do
    it {should contain_class('unity')}
  end
end
