# Class: rspec
#
# This module installs rspec_puppet testing prerequsities
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class rspec {
	package { 'rubygems':
		ensure => installed,
	} -> Package<| provider == 'gem' |>

	$build_dependencies = [ 'gcc', 'make', 'ruby-devel' ]

	package { [$build_dependencies]:
		ensure => installed,
	}

	package { 'bundler':
		ensure => installed,
		provider => 'gem',
	}

	$rspec_bundle_dir = '/var/lib/rspec_bundle'

	file { $rspec_bundle_dir:
		ensure => directory,
		mode => '0755',
	}

	file { "${rspec_bundle_dir}/Gemfile":
		source => 'puppet:///modules/rspec/Gemfile',
		mode => '0644',
	}

	exec { 'install-rspec_bundle':
		unless => 'bundle check',
		command => 'bundle install',
		cwd => $rspec_bundle_dir,
		timeout => 0,
		path => ['/usr/local/bin', '/bin', '/usr/bin'],
		require => [Package['bundler'], File["${rspec_bundle_dir}/Gemfile"], Package[$build_dependencies]],
	}

	$facts_injection_patch = '/usr/local/lib/facts_injection.patch'

	file { $facts_injection_patch:
		source => 'puppet:///modules/rspec/facts_injection.patch',
		owner => 'root',
		group => 'root',
		mode => '0644',
	}

	package { 'patch':
		ensure => installed,
	}

	exec { 'patch-rspec-puppet':
		unless => "patch --dry-run --reverse --force --quiet --strip=1 --input=\"${facts_injection_patch}\"",
		command => "patch --force --quiet --strip=1 --input=\"${facts_injection_patch}\"",
		cwd => '/usr/lib/ruby/gems/1.8/gems/rspec-puppet-0.1.3',
		path => ['/usr/local/bin', '/bin', '/usr/bin'],
		require => [Package['patch'], Exec['install-rspec_bundle'], File[$facts_injection_patch]],
	}

	file { "${settings::confdir}/hiera.yaml":
		content => ":backends:\n  - yaml\n",
		owner => 'root',
		group => 'root',
		mode => '0644',
	}
}
