module FactoryHelper
  def constants_include
    Object.send(:remove_const, :Customer) if Object.constants.include?(:Customer)
  end
end
