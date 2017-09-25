

class clgxutil::imageprep::ec2_windows {


  # Cleanup our build files
  $cleanup_commands = [
    "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
    "c:\\bootstrap\\WindowsPreBake.ps1"
  ]
  file_line { 'sysprep-cleanup':
    path => 'C:/Program Files/Amazon/Ec2ConfigService/Scripts/BeforeSysprep.cmd',
    line => join($cleanup_commands, ' ')
  }


  # Set EC2Config to setup as new host
  $ec2config = 'C:/Program Files/Amazon/Ec2ConfigService/Settings/config.xml'
  file {$ec2config:
    content => epp('clgxutil/imageprep/ec2config_config.xml.epp',
      {
        'ec2SetPassword'           => 'Enabled',
        'ec2SetComputerName'       => 'Enabled',
        'ec2DynamicBootVolumeSize' => 'Enabled',
        'ec2HandleUserData'        => 'Enabled',
      }
    )
  }

  # Set BundleConfig settings
  $bundleconfig = 'C:/Program Files/Amazon/Ec2ConfigService/Settings/BundleConfig.xml'
  file {$bundleconfig:
    content => epp('clgxutil/imageprep/ec2config_bundleconfig.xml.epp',
      {
        'autoSysprep'             => 'Yes',
        'setRDPCertificate'       => 'Yes',
        'setPasswordAfterSysprep' => 'Yes',
      }
    )
  }
}
