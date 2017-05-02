require "fio/version"
require "fio/install"

module Fio
	def self.benchmark
		
		if File.file?("/usr/local/bin/fio")
			output = `fio -v`
			puts "#{output} has been already installed"
		else
			include Install 
			Install.install
		end
		
	end
end

Fio.benchmark