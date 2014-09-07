# See README.md for details.
# Private define
define accounts::authorized_key(
  $ssh_key                 = regsubst($name, '^(\S+)-on-\S+$', '\1'),
  $account                 = regsubst($name, '^\S+-on-(\S+)$', '\1'),
  $options                 = undef,
  $target                  = undef,
) {
  if $ssh_key =~ /^@(\S+)$/ {
    if ! has_key($::accounts::usergroups, $1) {
      fail "Can't find usergroup : ${1}"
    }
    ensure_resource(
      accounts::authorized_key,
      suffix($::accounts::usergroups[$1], "-on-${account}"),
      {
        options => $options,
        target  => $target,
      }
    )
  } else {
    if ! has_key($::accounts::ssh_keys, $ssh_key) {
      fail "Can't find ${ssh_key} public_key in ::accounts::ssh_keys"
    }
    $__ensure = $::accounts::ssh_keys[$ssh_key]['ensure']
    $_ensure = $__ensure ? {
      absent  => absent,
      default => present,
    }
    $key_comment_format = getparam(Accounts::Account[$account], 'key_comment_format')
    $__name = strformat($key_comment_format)
    $_name = $__name ? {
      ''      => $name,
      default => $__name,
    }
    ssh_authorized_key { $name:
      ensure  => $_ensure,
      name    => $_name,
      key     => $::accounts::ssh_keys[$ssh_key]['public'],
      options => $options,
      target  => $target,
      type    => $::accounts::ssh_keys[$ssh_key]['type'],
      user    => $account,
    }
  }
}
