

class clgxutil::bootstrap::userdata_customfacts(
  Hash  $static_facts = {}
  ) {

  # Get the base64 encoded json in userdata, returned as Hash
  $userdata_facts = clgxutil::get_userdata_customfacts()
  $add_facts = merge($static_facts, $userdata_facts)

  if $add_facts {
    # Only apply if facts are found in case something else is
    # managing this elsewhere
    class {'static_custom_facts':
      purge_unmanaged => true,
      custom_facts    => $add_facts
    }
  }


}
