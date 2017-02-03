component accessors="true" singleton {
	property name='printBuffer'   inject='PrintBuffer';
	property name='fileSystem' 	  inject='FileSystem';
	
	public any function init() {
		
		return this;
	}

	public void function checkIP ( string server_id, string hostname='' ) {
		// os-specific new line delimiter
		var newline = server.separator.line;
	
		// get os-specific location of hosts file
		var hostsFile = variables.fileSystem.isWindows() ? 'C:/Windows/system32/drivers/etc/hosts' :
						variables.fileSystem.isMac() 	 ? '/private/etc/hosts' :
						variables.fileSystem.isLinux() 	 ? '/etc/hosts'		  :
						'';

		// check hosts file only if we have a file location and if the provided host name is not an ip address
		if ( hostsFile.len() && arguments.hostname.reFindNoCase( '[a-z]' ) ) {
			var hosts = fileRead( hostsFile ); 

			// only add host to file if it isn't already in there
			// use space and tab as possible list delimiters in order to avoid substring-matching
			if( !hosts.listFindNoCase(arguments.hostname, ' 	') ) {
				try {
					variables.printBuffer.greenLine( "Adding host '#arguments.hostname#' to your hosts file!" ).toConsole(); 
					var new_ip = getNewIP( hosts );

					fileAppend( hostsFile, "#newline##newline##new_ip#	#arguments.hostname# ## CommandBox: Server #arguments.server_id# #dateTimeFormat( now(), 'yyyy-mm-dd HH:nn:ss' )# " );
				}
				catch( any e ) {
					variables.printBuffer.boldRedLine( "Can't write to hosts file. Did you remember to start CommandBox with admin privileges?").toConsole();
				}
			}
		}

		return;
	}
	
	private string function getNewIP( required string hosts ) {
		var ip_array = arguments.hosts.reMatch( '127.127(\.[0-9]+){2}' ).sort( 'text', 'desc');

		if( ip_array.len() ) {
			var highest_ip = ip_array[1];
			var third_group = highest_ip.listGetAt( 3, '.' );
			var last_group = highest_ip.listLast( '.' );
			if(  last_group < 255 )
				last_group++;
			else {
				third_group++;
				last_group=1;
			}

			var new_ip = highest_ip.listSetAt( 3, third_group, '.' ).listSetAt( 4, last_group, '.' )
		}
		else 
			var new_ip = '127.127.0.1';

		return new_ip;
	}
	
}