package ch.capi.net.app {	import ch.capi.data.Set;	
	/**
	 * Contains all the <code>IApplicationContext</code> contained	 * into the application. This constants is intended to register	 * only <code>IApplicationContext</code> objects.	 * 	 * @example	 * <listing version="3.0">	 * var ctx:IApplicationContext = applicationContexts.getValue("appContext");	 * var file:ApplicationFile = ctx.getFile("appFile");	 * </listing>
	 */
	public const applicationContexts:Set = new Set(false);
}
