component accessors=true {

	public any function configure() {
		return;
	}

	
	public void function preServerStart( interceptData ) {
		wirebox.getInstance( 'hostupdaterService@commandbox-hostupdater' ).checkIP( arguments.interceptData.serverprops.host ?: '' );

		return;
	}
}