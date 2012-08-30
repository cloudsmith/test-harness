Puppet::Parser::Functions::newfunction(:gem_path, :type => :rvalue, :doc => "
  Takes a gem name and returns its intall location.
") do |arguments|
  raise(ArgumentError, "gem_path(): Wrong number of arguments given (#{arguments.size} for 1)") unless (arguments.size == 1)
  gem_name = arguments.shift()

  if Gem::Specification.respond_to?(:find_all_by_name)
    reset = false
    while true
      spec = Gem::Specification.find_all_by_name(gem_name, Gem::Requirement.default).last
      break if (spec || reset)
      Gem::Specification.reset()
      reset = true
    end
  else
    spec = Gem::SourceIndex.from_installed_gems().find_name(gem_name, Gem::Requirement.default).last
  end

  raise(ArgumentError, "#{gem_name} gem not installed") unless spec

  spec.full_gem_path
end
