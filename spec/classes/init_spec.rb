require 'spec_helper'
describe 'module_copy' do
  context 'with default values for all parameters' do
    it { should contain_class('module_copy') }
  end
end
