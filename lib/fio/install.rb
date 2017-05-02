module Install
	INSTALL_DIR = '~/opt/fio'
	FIO_VERSION = '2.19'
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
end