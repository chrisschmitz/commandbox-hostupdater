component accessors="true" singleton {
	property name='printBuffer'   inject='PrintBuffer';
	property name='fileSystem' 	  inject='FileSystem';
	
	public any function init() {
		
		return this;
	}

	public void function checkIP ( string server_id, string hostname='' ) {
		
		// get os-specific location of hosts file
		var hostsFile = getHostsFileName();

		// check hosts file only if we have a file location and if the provided host name is not an ip address
		if ( hostsFile.len() && arguments.hostname.reFindNoCase( '[a-z]' ) ) {
			var hosts = readHostsFileAsArray( hostsFile ); 

			// remove all lines that already contain either the server id or the host name
			// that way we can make sure that the hosts file doesn't grow indefinitely upon
			// changing the host name for an existing server
			hosts =  removeMatchingLines( hosts, [arguments.hostname,arguments.server_id] )
					.toList( server.separator.line ); // concatenate the array

			variables.printBuffer.greenLine( "Adding host '#arguments.hostname#' to your hosts file!" ).toConsole(); 
			var new_ip = getNewIP( hosts );
			hosts=hosts.listAppend( "#server.separator.line##new_ip#	#arguments.hostname# ## CommandBox: Server #arguments.server_id# #dateTimeFormat( now(), 'yyyy-mm-dd HH:nn:ss' )#", server.separator.line ) // add the line for the new host entry
					
			saveHostsFile( hostsFile, hosts );
				
			
		}

		return;
	}

	public void function forgetServer( required string server_id ){
		var hostsFile = getHostsFileName();
		var hosts = readHostsFileAsArray( hostsFile );

		variables.printBuffer.greenLine( "Removing host for server '#arguments.server_id#' from your hosts file!" ).toConsole(); 

		// remove all lines that contain the server id 
		// and concatenate the array  
		hosts = removeMatchingLines( hosts, [arguments.server_id] )
				.toList( server.separator.line ); 

		saveHostsFile( hostsFile, hosts );
		
		return;
	}

	private string function getHostsFileName() {
		return  variables.fileSystem.isWindows() ? 'C:/Windows/system32/drivers/etc/hosts' :
				variables.fileSystem.isMac() 	 ? '/private/etc/hosts' :
				variables.fileSystem.isLinux() 	 ? '/etc/hosts'		  :
				'';
	}

	private array function readHostsFileAsArray( required string hostsFile ) {
		return fileRead( arguments.hostsFile ).listToArray( server.separator.line );
	}

	private any function removeMatchingLines( required array hosts, required array expressions ){
		
		for( var elem in arguments.expressions ) {
			arguments.hosts = arguments.hosts.filter( function( line ) {
			 					return !line.listFindNoCase( elem, ' 	' ); 
							  });
		}
		
		return arguments.hosts;
	}	

	private string function getNewIP( required string hosts ) {
		// get all 127.127.xxx.yyy entries
		var ip_array = arguments.hosts.reMatch( '127.127(\.[0-9]+){2}' );

		if( ip_array.len() ) {
			// get highest third group
			var group_3 = ip_array.map( function ( address ){
								return address.listGetAt( 3, '.' );
						  }).sort( 'numeric', 'desc' )[1];

			// take all addresses that match 127.127. + group_3
			// then get highest last group from that set
			var group_4 = ip_array.filter( function( address ) {
								return address.listGetAt( 3, '.' ) == group_3;
						  })
						  .map( function ( address ) { 
								return address.listLast( '.' );
						  }).sort( 'numeric', 'desc' )[1];

			group_3 = group_4 < 255 ? group_3 	: group_3+1;
			group_4 = group_4 < 255 ? group_4+1 : 1;

			var new_ip = '127.127.#group_3#.#group_4#';
		}
		else 
			var new_ip = '127.127.0.1';

		return new_ip;
	}

	private void function saveHostsFile( string fileName, string fileContent ) {
		try {
			fileWrite( arguments.fileName, arguments.fileContent );
		}
		catch ( any e ) {
			variables.printBuffer.boldRedLine( "Can't write to hosts file. Did you remember to start CommandBox with admin privileges?" ).toConsole();
		}

		return;
	}
	
}