require "fio/version"
require "fio/install"

module Fio
	include Install
	def self.benchmark
		
		if File.file?("/usr/local/bin/fio")
			output = `fio -v`
			puts "#{output} has been already installed"
		else
			 install
		end
		
	end
end

Fio.benchmark