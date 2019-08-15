module FactoryHelper
  def constants_include
    if Object.constants.include?(:Customer)
      Object.send(:remove_const, :Customer)
    end
  end
end
