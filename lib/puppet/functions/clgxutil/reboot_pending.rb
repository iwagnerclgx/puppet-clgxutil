# Reboot logic from puppetlabs-reboot module
# https://github.com/puppetlabs/puppetlabs-reboot/blob/master/lib/puppet/provider/reboot/windows.rb


Puppet::Functions.create_function(:'clgxutil::reboot_pending') do

  dispatch :get_status do
    #No Args
  end


  def get_status()
    scope = closure_scope
    unless scope['facts']['kernel'] == "Windows" then
      return component_based_servicing? ||
        windows_auto_update? ||
        pending_file_rename_operations? ||
        package_installer? ||
        package_installer_syswow64? ||
        pending_computer_rename? ||
        pending_dsc_reboot? ||
        pending_ccm_reboot?
    end
    false
  end

  def vista_sp1_or_later?
    # this errors if this is not a control flow construct
    scope = closure_scope
    match = scope['facts']['kernelversion'].match(/\d+\.\d+\.(\d+)/) and match[1].to_i >= 6001
  end

  def component_based_servicing?
    return false unless vista_sp1_or_later?

    # http://msdn.microsoft.com/en-us/library/windows/desktop/aa370556(v=vs.85).aspx
    path = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    pending = key_exists?(path)
    pending
  end

  def windows_auto_update?
    path = 'SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    pending = key_exists?(path)
    pending
  end

  def pending_file_rename_operations?
    pending = false

    path = 'SYSTEM\CurrentControlSet\Control\Session Manager'
    with_key(path) do |reg|
      renames = reg.read('PendingFileRenameOperations') rescue nil
      if renames
        pending = renames[1].length > 0
        if pending
        end
      end
    end

    pending
  end

  def package_installer?
    # http://support.microsoft.com/kb/832475
    # 0x00000000 (0)	No pending restart.
    path = 'SOFTWARE\Microsoft\Updates'
    value = reg_value(path, 'UpdateExeVolatile')
     # this may error if this is not a control flow construct
    if value and value != 0
      true
    else
      false
    end
  end

  def package_installer_syswow64?
    # http://support.microsoft.com/kb/832475
    # 0x00000000 (0)	No pending restart.
    path = 'SOFTWARE\Wow6432Node\Microsoft\Updates'
    value = reg_value(path, 'UpdateExeVolatile')
    # this may error if this is not a control flow construct
    if value and value != 0
      true
    else
      false
    end
  end

  def pending_computer_rename?
    path = 'SYSTEM\CurrentControlSet\Control\ComputerName'
    active_name = reg_value("#{path}\\ActiveComputerName", 'ComputerName')
    pending_name = reg_value("#{path}\\ComputerName", 'ComputerName')
    if active_name && pending_name && active_name != pending_name
      true
    else
      false
    end
  end

  def pending_dsc_reboot?
    require 'win32ole'
    root = 'winmgmts:\\\\.\\root\\Microsoft\\Windows\\DesiredStateConfiguration'
    reboot = false

    begin
      dsc = WIN32OLE.connect(root)

      lcm = dsc.Get('MSFT_DSCLocalConfigurationManager')

      config = lcm.ExecMethod_('GetMetaConfiguration')
      reboot = config.MetaConfiguration.LCMState == 'PendingReboot'
    rescue
    end
    reboot
  end

  def pending_ccm_reboot?
    require 'win32ole'
    root = 'winmgmts:\\\\.\\root\\ccm\\ClientSDK'
    reboot = false

    begin
      ccm = WIN32OLE.connect(root)

      ccm_client_utils = ccm.Get('CCM_ClientUtilities')

      pending = ccm_client_utils.ExecMethod_('DetermineIfRebootPending')
      reboot = (pending.ReturnValue == 0) && (pending.IsHardRebootPending || pending.RebootPending)
    rescue
    end
    reboot
  end


  def with_key(name, &block)
    require 'win32/registry'

    Win32::Registry::HKEY_LOCAL_MACHINE.open(name, Win32::Registry::KEY_READ | 0x100) do |reg|
      yield reg if block_given?
    end

    true
  rescue
    false
  end

  def reg_value(path, value)
    rval = nil

    with_key(path) do |reg|
      rval = reg.read(value)[1]
    end

    rval
  end

  def key_exists?(path)
    with_key(path)
  end

end
