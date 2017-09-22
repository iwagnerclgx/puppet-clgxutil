
Puppet::Functions.create_function(:global_findmodule) do 

  dispatch :findmod do
    param 'String', :modulename
  end

  def findmod(modulename)
    if module_path = Puppet::Module.find(modulename)
      module_path.path
    else
      raise(Puppet::ParseError, "Could not find module #{modulename}")
    end
  end

end
