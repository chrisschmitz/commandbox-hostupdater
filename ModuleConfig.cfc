component accessors=true {
	
	public any function configure() {
		return;
	}

	
	public void function preServerStart( interceptData ) {
		var systemSettings = wirebox.getInstance( 'SystemSettings' );
		var serverJSON = systemSettings.expandSystemSettings( duplicate( arguments.interceptData.serverDetails.serverJSON ) );
		
		var hostname = 	arguments.interceptData.serverProps.host 				  ?: 			// host provided on the command line?
						serverJSON.web.host ?:			// host provided in server.json?
						wirebox.getInstance( 'ServerService' ).getDefaultServerJSON().web.host; // if nothing was provided, use default (127.0.0.1)

		var aliases  =  arguments.interceptData.serverProps.hostAlias					?:		// hostAlias provided on the command line?
						serverJSON.web.hostAlias 	?:		// hostAlias provided 'web' section of server.json?
						serverJSON.hostAlias 		?:		// hostAlias provided in server.json?
						[];																		// if nothing was provided, use default (empty array)

		if( !isArray( aliases ))
			aliases = aliases.listToArray();

		arraySort( aliases, 'text' );

		if( !isEmpty( aliases ) )
			arguments.interceptData.serverDetails.serverJSON["web"]["hostAlias"] = duplicate( aliases );

		var ary = duplicate( aliases );
		ary = ary.prepend( hostname )
					.reduce( function( arr, alias ){
					if( alias.reFindNoCase( '[a-z]') && !arr.find( alias ) ){
						arr.append( alias );
					}
					return arr;
					}, [] );

		wirebox.getInstance( 'hostupdaterService@commandbox-hostupdater' ).checkIP( arguments.interceptData.serverDetails.serverInfo.id, ary );
		
		structDelete( arguments.interceptData.serverProps, "hostAlias", false );
		structDelete( arguments.interceptData.serverDetails.serverJSON, 'hostAlias', false );

		return;
	}

	public void function postServerForget( interceptData ) {
		
		wirebox.getInstance( 'hostupdaterService@commandbox-hostupdater' ).forgetServer( arguments.interceptData.serverInfo.id );

		return;
	}
}
