package ch.capi.display
{
	import ch.capi.net.ILoadableFile;
	
	/**
	 * Represents an <code>IRootDocument</code>.
	 * 
	 * @version	1.0
	{
		/**
		 * Callback of the MassLoader for the SWF that should know the <code>ILoadableFile</code>
		 * within there were loaded. If a document class implements the <code>IRootDocument</code>
		 * interface, the <code>MassLoader</code> will automatically call this method.
		 * 
		 * @param	loadableFile	The <code>ILoadableFile</code> source.
		 */
		function initializeContext(loadableFile:ILoadableFile):void;