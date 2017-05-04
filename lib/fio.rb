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
		models = []
		disks = []
		model_output.each_line do |line|
			models << line.strip
		end
		disk_output.each_line do |line|
			disks << line
		end
		models.zip(disks)
	end

	def benchmark
		
		# if File.file?("/usr/local/bin/fio")
		# 	output = `fio -v`
		# 	puts "#{output} has been already installed"
		# else
		# 	install
		# end

		job_dir = File.expand_path('../fio/job_file', __FILE__)

		# Detect disk information 
		devices = get_device_info
		devices.each do |key, value| 
			Dir.foreach(job_dir) do |file|
				if file.include? "job_file_"
					output =`sudo DISK=#{value} fio #{job_dir}/#{file}`
					puts output
				end
			end
		end
		
		
	end
end

Fio.benchmark