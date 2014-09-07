Puppet::Parser::Functions.newfunction(:build_accounts_authorized_keys_hash, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
  Private function
  ENDHEREDOC

  raise(Puppet::ParseError, "build_accounts_authorized_keys_hash(): Wrong number of arguments given") if args.size != 2
  raise(Puppet::ParseError, "build_accounts_authorized_keys_hash(): First parameter must be a String, an Array or a Hash") if args[0].class != String and args[0].class != Array and args[0].class != Hash
  raise(Puppet::ParseError, "build_accounts_authorized_keys_hash(): Second parameter must be a String") if args[1].class != String

  authorized_keys, account = args

#  puts "authorized_keys = #{authorized_keys}"
#  puts "account = #{account}"
#  puts "authorized_keys.class = #{authorized_keys.class}"

  result = {}
  case authorized_keys
  when String
    #puts "#{authorized_keys} is a String"
    result["#{authorized_keys}-on-#{account}"] = {
      :ssh_key => authorized_keys,
    }
  when Array 
    #puts "#{authorized_keys} is an Array"
    authorized_keys.each do |k|
      result["#{k}-on-#{account}"] = {
        :ssh_key => k,
      }
    end
  when Hash
    #puts "#{authorized_keys} is a Hash"
    authorized_keys.each do |k, v|
      result["#{k}-on-#{account}"] = {
        :ssh_key => k,
        :options => v,
      }
    end
  else
    raise(Puppet::Error, "#{authorized_keys}'s class is #{authorized_keys.class}, should be one of String, Array or Hash")
  end

  #puts result
  return result

end
