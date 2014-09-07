# See README.md for details.
define accounts::account(
  $ensure                   = present,
  $user                     = $name,
  $groups                   = [],
  $authorized_keys          = [],
  $target_format            = $::accounts::target_format,
  $key_comment_format       = $::accounts::key_comment_format,
) {
  if $user =~ /^@(\S+)$/ {
    if ! has_key($::accounts::usergroups, $1) {
      fail "Can't find usergroup : ${1}"
    }
    ensure_resource(
      accounts::account,
      $::accounts::usergroups[$1],
      {
        ensure                   => $ensure,
        groups                   => $groups,
        authorized_keys          => $authorized_keys,
        target_format            => $target_format,
        key_comment_format       => $key_comment_format,
      }
    )
  } else {
    # Retrieve $ssh_keys and $users in the current scope
    $ssh_keys = $::accounts::ssh_keys
    $users    = $::accounts::users

    $_target = strformat($target_format) ? {
      ''      => undef,
      default => strformat($target_format),
    }

    if $ensure != absent {
      if has_key($users, $user) {
        ensure_resource(
          user,
          $user,
          merge(
            $users[$user],
            {
              ensure     => $ensure,
              groups     => $groups,
              managehome => true,
            }
          )
        )
      }

      if has_key($ssh_keys, $user) {
        if is_string($authorized_keys) {
          $_authorized_keys = unique(concat([$authorized_keys], $user))
        } elsif is_array($authorized_keys) {
          $_authorized_keys = unique(concat($authorized_keys, $user))
        } elsif is_hash($authorized_keys) {
          $_authorized_keys = merge({ "${user}" => {}}, $authorized_keys)
        } else {
          $_authorized_keys = $authorized_keys
        }
        if has_key($ssh_keys[$user], 'private') {
          # NOTE: getparam(User[$user], 'home') would do the trick to fetch
          # user's home dir, but it depends on parsing order
          #
          # $home = getparam(User[$user], 'home')
          # file { "${home}/.ssh/id_rsa":
          #   content => $ssh_keys[$user]['private'],
          # }
          #
          # Another solution would be to use puppetdbquery:
          #
          # $ret = query_resources("fqdn='${::fqdn}'", "User['${user}']")
          # $home = $ret[$::fqdn][0]['parameters']['home']
          #
          # TODO: Fix unless so that it replaces the key
          exec { "/bin/echo '${ssh_keys[$user]['private']}' > ~${user}/.ssh/id_rsa":
            unless => "/usr/bin/test -f ~${user}/.ssh/id_rsa",
          }
        }
      } else {
        $_authorized_keys = $authorized_keys
      }

      create_resources(
        accounts::authorized_key,
        build_accounts_authorized_keys_hash( $_authorized_keys, $user ),
        {
          account => $user,
          target  => $_target,
        }
      )
    }

    # TODO: Use class user's purge parameter instead
    create_resources(
      accounts::authorized_key,
      build_accounts_authorized_keys_hash(
        keys(absents($ssh_keys)),
        $user
      ),
      {
        account => $user,
        target  => $_target,
      }
    )

  }
}
