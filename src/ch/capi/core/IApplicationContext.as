package ch.capi.core 
{
	import ch.capi.net.ILoadableFile;
	
	/**
	 * Represents an <code>IApplicationContext</code>.
	 * 	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public interface IApplicationContext
	{
		/**
		 * Callback of the MassLoader for the SWF that should know the <code>ILoadableFile</code>
		 * within there were loaded. If a document class implements the <code>IApplicationContext</code>
		 * interface, the <code>MassLoader</code> will automatically call this method.
		 * 
		 * @param	loadableFile	The <code>ILoadableFile</code> source.
		 */
		function initializeContext(loadableFile:ILoadableFile):void;	}}