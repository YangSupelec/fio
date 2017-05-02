require "fio/version"
require "fio/install"

module Fio
	def self.benchmark
		output = `fio -v`
		if $?.exitstatus > 0
			include Install 
			install
		else
			puts "#{output} has been already installed"
		end
		
	end
end

benchmark