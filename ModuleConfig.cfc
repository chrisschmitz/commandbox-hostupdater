component accessors=true {

	public any function configure() {
		return;
	}


	public void function preServerStart( interceptData ) {
		var hostname = 	arguments.interceptData.serverProps.host 				  ?: 			// host provided on the command line?
						arguments.interceptData.serverDetails.serverJSON.web.host ?:			// host provided in server.json?
						wirebox.getInstance( 'ServerService' ).getDefaultServerJSON().web.host; // if nothing was provided, use default (127.0.0.1)

		var hostAlias = arguments.interceptData.serverProps.hostAlias			  		?: 			// host provided on the command line?
						arguments.interceptData.serverDetails.serverJSON.web.hostAlias 	?:			// host provided in server.json?
						''; // No alias was provided.

		if (isArray(hostAlias) && !arrayIsEmpty(hostAlias)) {
			hostAlias = arrayToList(hostAlias, " ");
		}

		if (len(hostAlias) GT 0) {
			hostname &= " " & hostAlias;
		}

		wirebox.getInstance( 'hostupdaterService@commandbox-hostupdater' ).checkIP( arguments.interceptData.serverDetails.serverInfo.id, hostname );

		return;
	}

	public void function postServerForget( interceptData ) {

		wirebox.getInstance( 'hostupdaterService@commandbox-hostupdater' ).forgetServer( arguments.interceptData.serverInfo.id );

		return;
	}
}