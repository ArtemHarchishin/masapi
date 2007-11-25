package ch.capi.core 
{	import ch.capi.net.INetStateManager;
	import ch.capi.net.ILoadableFile;
	
	/**
	 * Represents an <code>IApplicationContext</code>.
	 * 	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public interface IApplicationContext extends INetStateManager
	{
		/**
		 * Defines the <code>ILoadableFile</code> of the application context. This value is set when the
		 * <code>Event.INIT</code> event is dispatched from the <code>ILoadableFile</code> where
		 * it is loaded. If the document isn't loaded using a Loader <code>ILoadableFile</code>
		 * (<code>LoadableFileFactory.createLoaderFile()), then this value won't be initialized.
		 * 
		 * @see		ch.capi.net.LoadableFileFactory#createLoaderFile()	LoadableFileFactory.createLoaderFile()
		 */
		function get linkedLoadableFile():ILoadableFile;
		function set linkedLoadableFile(value:ILoadableFile):void;	}}