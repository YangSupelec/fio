require "fio/version"

module Fio
	INSTALL_DIR = '~/opt/fio'
	FIO_VERSION = '2.19'
	module_function
	def install
		# Update ubuntu package manager
		system "sudo apt-get update"

		# Install base package
		system "sudo apt-get install build-essential libaio-dev -y"
		if $?.exitstatus > 0
  			puts "Failed to install basic package." 
		end

		# Create installation directory if missed
		unless File.directory?(INSTALL_DIR)
			system "mkdir -p #{INSTALL_DIR}"
		end

		# Install fio from source code
		if $?.exitstatus == 0
			system "cd #{INSTALL_DIR} && wget http://brick.kernel.dk/snaps/fio-#{FIO_VERSION}.tar.bz2 && \
					tar -xjvf fio-#{FIO_VERSION}.tar.bz2 && \
					cd fio-#{FIO_VERSION} && ./configure && make && sudo make install"
			# Check install version
			if $?.exitstatus == 0
				output = `fio -v`
				puts output
			end
		end
	end

	def get_device_info
		model_output = `sudo parted -l|grep Model|awk -F ":" '{print $2}'`
		disk_output = `sudo parted -l|grep "Disk /"|awk -F ":| " '{print $2}'`
		model_list = []
		disk_list = []
		model_output.each_line do |line|
			model_list << line
		end
		disk_output.each_line do |line|
			disk_list << line
		end
		puts model_list[0]
		puts disk_list[0]
	end

	def benchmark
		
		# if File.file?("/usr/local/bin/fio")
		# 	output = `fio -v`
		# 	puts "#{output} has been already installed"
		# else
		# 	install
		# end

		# Detect disk information 


		lib = File.expand_path('../fio/job_file', __FILE__)
		Dir.foreach(lib) { |file|
			if file.include? "job_file_"
				puts "#{lib}/#{file}"
			end
			#output =`sudo DISK=/dev/sda fio #{file}`
			#puts output
		}
		
		
	end
end

Fio.get_device_info