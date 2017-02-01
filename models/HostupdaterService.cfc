component accessors="true" singleton {
	property name='printBuffer' inject='PrintBuffer';
	property name='fileSystem' inject='FileSystem';
	
	public any function init() {
		
		return this;
	}

	public void function checkIP ( string hostname='' ) {
		var osname  = variables.fileSystem.isMac() ? 'mac' :  variables.fileSystem.isLinux() ? 'linux' : 'windows';
		var newline = chr( 10 );
	
		switch ( osname ){
			case 'windows':
				var hostsFile = 'C:/Windows/system32/drivers/etc/hosts'
				newline 	  = chr( 13 ) & chr( 10 );
				break;

			case 'linux':
				var hostsFile = '/etc/hosts';
				break;

			case 'mac':
				var hostsFile = '/private/etc/hosts';
				break;

			default:
				var hostsFile = '';
		}

		if ( hostsFile.len() && arguments.hostname.len() && reFindNoCase( '[a-z]', arguments.hostname ) ) {
			var hosts = fileRead( hostsFile );

			if( !findNoCase( arguments.hostname, hosts ) ) {
				try {
					variables.printBuffer.greenLine( "Adding host '#arguments.hostname#' to your hosts file!" ).toConsole(); 
					var new_ip = getNewIP( hosts );

					fileAppend( hostsFile, "#newline##newline######### Added by CommandBox #dateTimeFormat( now(), 'yyyy-mm-dd HH:nn:ss' )# ########" );
					fileAppend( hostsFile, '#newline##new_ip#	#arguments.hostname#');
				}
				catch( any e ) {
					variables.printBuffer.boldRedLine( "Can't write to hosts file. Did you remember to start CommandBox with admin privileges?").toConsole();
				}
			}
		}

		return;
	}
	
	private string function getNewIP( required string hosts ) {
		var ip_array = reMatch( '127.127(\.[0-9]+){2}', arguments.hosts ).sort( 'text', 'desc');

		if( ip_array.len() ) {
			var highest_ip = ip_array[1];
			var third_group = listGetAt(highest_ip, 3, '.' );
			var last_group = listLast( highest_ip, '.');
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