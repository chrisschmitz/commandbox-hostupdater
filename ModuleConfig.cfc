component accessors=true {
	
	public any function configure() {
		return;
	}

	
	public void function preServerStart( interceptData ) {
		var hostname = 	arguments.interceptData.serverProps.host 				  ?: 			// host provided on the command line?
						arguments.interceptData.serverDetails.serverJSON.web.host ?:			// host provided in server.json?
						wirebox.getInstance( 'ServerService' ).getDefaultServerJSON().web.host; // if nothing was provided, use default (127.0.0.1)

		var aliases  =  arguments.interceptData.serverProps.hostAlias					?:		// hostAlias provided on the command line?
						arguments.interceptData.serverDetails.serverJSON.web.hostAlias 	?:		// hostAlias provided 'web' section of server.json?
						arguments.interceptData.serverDetails.serverJSON.hostAlias 		?:		// hostAlias provided in server.json?
						[];																		// if nothing was provided, use default (empty array)

		var systemSettings = wirebox.getInstance( 'SystemSettings' );
		
		if( !isArray( aliases ))
			aliases = aliases.listToArray();

		arraySort( aliases, 'text' );

		if( !isEmpty( aliases ) )
			arguments.interceptData.serverDetails.serverJSON["web"]["hostAlias"] = duplicate( aliases );

		var ary = duplicate( aliases);
		ary = ary.prepend( hostname )
					.reduce( ( arr, alias ) => {
					if( alias.reFindNoCase( '[$a-z]') && !arr.find( alias ) ){
						// [CS] [2018-03-15] if the alias is a system var, use the evaluated value
						if( left( alias, 1 ) == '$' )
							alias = systemSettings.expandSystemSettings( alias );

						arr.append( alias );

					}

					return arr;
					}, [] )
					.filter( ( host ) => host != 'localhost' );

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
