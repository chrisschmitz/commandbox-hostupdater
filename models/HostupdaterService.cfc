component accessors="true" singleton {
	property name='consoleLogger' inject='logbox:logger:console';
	property name='fileSystem' 	  inject='FileSystem';
	property name='wb'			  inject="WireBox";
	property name="hostsFile";
	property name="hostsFileReadable";
	property name="hostsFileWritable";
	property name="hosts";

	public any function init( any fileSystem inject="FileSystem" ) {
		variables.fileSystem = arguments.fileSystem;
		checkHostsFile();
		
		return this;
	}

	public void function checkIP ( string server_id, array hostnames=[] ) {
		

		// check hosts file only if we have a file location and if the provided host name array is not empty
		if ( variables.hostsFile.len() && arguments.hostnames.len() ) {
			variables.hostaliases = readHostsFileAsArray( hostsFile ); 

			// remove all lines that already contain the server id 
			// that way we can make sure that the hosts file doesn't grow indefinitely upon
			// changing the host name for an existing server
			removeOldEntriesFromHostsfile( arguments.server_id );

			var new_ip = getNewIP( variables.hostaliases.toList( server.separator.line ) );

			for( var hostname in arguments.hostnames ) {
				variables.consoleLogger.info( "Adding host '#hostname#' to your hosts file!" );
				// remove any line matching the current host name
				// in order to avoid duplicate entries
				removeOldEntriesFromHostsfile( hostname );

				// add the line for the new host entry
				addNewHostname( "#new_ip#     #hostname# ## CommandBox: Server #arguments.server_id# #dateTimeFormat( now(), 'yyyy-mm-dd HH:nn:ss' )#" );
			}
			
			// on Windows only: write to hosts file (on *nix hosts file is modified directly by sed)
			if( variables.fileSystem.isWindows() )
				saveHostsFile();
		}

		return;
	}

	private void function checkHostsFile() {

		// get os-specific location of hosts file
		variables.hostsFile = getHostsFileName();

		var hostsFileReader = createObject( 'java', 'java.io.File').init( hostsFile );
		variables.hostsFileReadable = hostsFileReader.canRead();
		variables.hostsFileWritable = hostsFileReader.canWrite();

		return;
	}

	public void function forgetServer( required string server_id ){
		variables.hostaliases = readHostsFileAsArray( );

		variables.consoleLogger.info( "Removing host(s) for server '#arguments.server_id#' from your hosts file!" ); 

		// remove all lines that contain the server id 
		removeOldEntriesFromHostsfile( arguments.server_id );

		if( variables.fileSystem.isWindows() )
			saveHostsFile();
		
		return;
	}

	private string function getHostsFileName() {
		return  variables.fileSystem.isWindows() ? 'C:\Windows\system32\drivers\etc\hosts' :
				variables.fileSystem.isMac() 	 ? '/private/etc/hosts' :
				variables.fileSystem.isLinux() 	 ? '/etc/hosts'		  :
				'';
	}

	private array function readHostsFileAsArray() {
		return fileRead( variables.hostsFile ).listToArray( server.separator.line );
	}

	private void function removeOldEntriesFromHostsfile( required string id_or_hostname ){

		if( !variables.fileSystem.isWindows() ) {
			local.sedOptArg = variables.fileSystem.isMac() ? " ''" : ""; 
			// remove by hostname
			sudo( "sed -E -i#local.sedOptArg# '/127\.[0-9.]+ +#arguments.id_or_hostname.replace('.', '\.', 'all')# .+/d' #getHostsFileName()#" );
			// remove by id, if it is very probably an id
			if (len(arguments.id_or_hostname) gte 32 and refind('[0-9A-Fa-f]{32}', arguments.id_or_hostname) eq 1) {
				sudo( "sed -i#local.sedOptArg# '/.* #arguments.id_or_hostname# .*/d' #getHostsFileName()#" );
			}
		} else {
			removeMatchingLines( [id_or_hostname] );
		}
		return;
	}

	private void function removeMatchingLines( required array expressions ){
		
		if( !isArray( variables.hostaliases ) || !variables.hostaliases.len() )
			variables.hostaliases = readHostsFileAsArray();

		for( var elem in arguments.expressions ) {
			variables.hostaliases = variables.hostaliases.filter( function( line ) {
			 					return !line.listFindNoCase( elem, ' 	' ); 
							  });
		}
		
		return;
	}	

	private void function addNewHostname( required string entry ){

		if( !variables.fileSystem.isWindows() ) {
			if( variables.fileSystem.isMac() ) {
				sudo( "sed -i '' '$ a\'$'\n''#arguments.entry#'  #getHostsFileName()#" );
			} else {
				sudo( "sed -i '$ a #arguments.entry#'  #getHostsFileName()#" );
			}
		} else {
			 variables.hostaliases.append( arguments.entry );
		}

		return;
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

		// MacOS per default only recognizes 127.0.0.1 as local address
		// in order for it to accept other addresses, we must tell
		// MacOS that this new address is a local loopback address, too
		if( variables.fileSystem.isMac() )
			sudo( "ifconfig lo0 alias #new_ip# up" );
		return new_ip;
	}

	private void function saveHostsFile() {
		try {
			fileWrite( variables.hostsFile, variables.hostaliases.toList( server.separator.line )  )
			// Give the OS a chance to write the file
			sleep( 300 );
		}
		catch ( any e ) {
			variables.consoleLogger.error( "Can't write to hosts file. Did you remember to start CommandBox with " & ( variables.fileSystem.isWindows() ? "admin" : "root" ) & " privileges?" );
		}

		return;
	}
	
	private any function sudo( required string cmdstring ){
		try {
			return wb.getinstance( name='CommandDSL', initArguments={ name : "run sudo " & arguments.cmdstring  } )
			.run(echo:false);
			//variables.printBuffer.boldRedLine( arguments.cmdstring ).toConsole();
		}
		catch ( any e ){
			variables.consoleLogger.error( "Oh my! Something went wrong when trying to modify the hosts file!" );
		}
	}

}
