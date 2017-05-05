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
		model_output = `sudo parted -l|grep 'Model.*scsi'|awk -F ":" '{print $2}'`
		disk_output = `sudo parted -l|grep 'Disk /dev/sd'|awk -F ":| " '{print $2}'`
		models = []
		disks = []
		model_output.each_line do |line|
			models << line.strip
		end
		disk_output.each_line do |line|
			disks << line.strip
		end
		models.zip(disks)
	end

	def post_process_benchmark_key(output)
		key = ""
		if output.include?("seq_read")
			key = "SR"
		elsif output.include?("seq_write")
			key = "SW"
		elsif output.include?("rand_read")
			key = "RR"
		else
			key = "RW"
		end

		return key		
	end

	def post_process_benchmark_value(output)
		arr = output.split(%r{,|=})
		res = Hash.new
		res[arr[0]] = arr[1]
		res[arr[2]] = arr[3]
		return res
	end

	def benchmark
		
		if File.file?("/usr/local/bin/fio")
			output = `fio -v`
			puts "#{output} has been already installed"
		else
			install
		end

		job_dir = File.expand_path('../fio/job_file', __FILE__)

		# Detect disk information 
		devices = get_device_info
		disk_result = Hash.new
		devices.each do |key, value| 
			# Format the benchmark result of every device to a hash object
			device_result = Hash.new
			Dir.foreach(job_dir) do |file|
				if file.include? "job_file_"
					job_key = post_process_benchmark_key(file)

					value_output =`sudo DISK=#{value} fio #{job_dir}/#{file} | grep -E 'BW' | awk '{print $2 $3}'`
					job_value = post_process_benchmark_value(value_output)
					device_result[job_key] = job_value
				end
			end
			disk_result[key] = device_result
		end

		# Write result to a json file
		puts disk_result
		puts disk_result.to_s
	
	end
end

Fio.benchmark