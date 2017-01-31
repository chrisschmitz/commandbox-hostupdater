component accessors=true {
	property name='hostupdaterService';
	property name="WireBox";

	public any function configure() {
		variables.hostupdaterService = new models.HostupdaterService( wirebox );
		return;
	}

	
	public void function preServerStart( interceptData ) {
		variables.hostupdaterService.checkIP( arguments.interceptData.serverprops.host ?: '' );

		return;
	}
}