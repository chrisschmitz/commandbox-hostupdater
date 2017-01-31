component accessors="true" singleton {
	property name='fileSystemUtil';
	property name='hostsFile';
	property name='crlf';
	property name='printBuffer';
	property name="wireBox";
	
	public any function init( any wirebox ) {

		variables.wirebox = arguments.wirebox;
		variables.fileSystemUtil = variables.wirebox.getInstance( "FileSystem" );
		variables.printBuffer 	 = variables.wireBox.getInstance( 'PrintBuffer' );

		var osname = fileSystemUtil.isMac() ? 'mac' :  fileSystemUtil.isLinux() ? 'linux' : 'windows';
	
		switch ( osname ){
			case 'windows':
				variables.hostsFile = 'C:/Windows/system32/drivers/etc/hosts';
				variables.crlf      = chr( 13 ) & chr( 10 );
				break;

			case 'linux':
				variables.hostsFile = '/etc/hosts';
				variables.crlf      = chr( 10 );
				break;

			case 'mac':
				variables.hostsFile = '/private/etc/hosts';
				variables.crlf      = chr( 10 );
				break;

			default:
				variables.hostsFile = '';
				variables.crlf      = '';
		}

		return this;
	}

	public void function checkIP ( string hostname='' ) {
		if ( hostsFile.len() && arguments.hostname.len() && reFindNoCase( '[a-z]', arguments.hostname ) ) {
			var hosts = fileRead( hostsFile );

			if( !findNoCase( arguments.hostname, hosts ) ) {
				printBuffer.greenLine( "Adding host '#arguments.hostname#' to your hosts file!" ).toConsole(); 
				var new_ip = getNewIP( hosts );
				fileAppend( hostsFile, "#crlf##crlf######### Added by CommandBox #dateTimeFormat( now(), 'yyyy-mm-dd HH:nn:ss' )# ########" );
				fileAppend( hostsFile, '#crlf##new_ip#	#arguments.hostname#');
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