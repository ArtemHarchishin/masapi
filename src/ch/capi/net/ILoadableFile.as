package ch.capi.net
{
	import flash.net.URLRequest;
	import flash.events.IEventDispatcher;
	import ch.capi.data.IMap;
	
	/**
	 * Dispatched if a call to <code>start()</code> results in a fatal error that terminates the download. 
	 * 
	 * @eventType	flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	
	/**
	 * Dispatched if a call to <code>start()</code> attempts to load data from a server outside the security sandbox. 
	 * 
	 * @eventType	flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	/**
	 * Represents a loadable file.
	 * 
	 * @see			ch.capi.net.AbstractLoadableFile	AbstractLoadableFile
	 * @see			ch.capi.net.LoadableFileFactory		LoadableFileFactory
	 * @see			ch.capi.net.LoadableFileType		LoadableFileType
	 * @see			ch.capi.net.ILoadableFileSelector	ILoadableFileSelector
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public interface ILoadableFile extends ILoadManager, INetStateManager
	{
		/**
		 * Defines the properties stored into the
		 * <code>ILoadableFile</code>.
		 */
		function get properties():IMap;
		
		/**
		 * Defines the <code>URLRequest</code> object that specify the
		 * URL to load.
		 */
		function get urlRequest():URLRequest;
		function set urlRequest(request:URLRequest):void;
		
		/**
		 * Defines the virtual total bytes. This value
		 * represents an approximation of the total bytes.
		 * This value should be greather than the real amount
		 * of bytes of the loadable file.
		 */
		function get virtualBytesTotal():uint;
		function set virtualBytesTotal(value:uint):void;
		
		/**
		 * Defines the load manager object. This object can be a
		 * <code>Loader</code> or a </code>URLLoader</code>.
		 */
		function get loadManagerObject():Object;
		
		/**
		 * Retrieves the <code>IEventDispatcher</code> of all the sub-events
		 * of a <code>ILoadableFile</code>. For example, the source event dispatcher
		 * of a <code>Loader</code> object will be his <code>contentLoaderInfo</code>.
		 * 
		 * @return	The <code>IEventDispatcher</code>.
		 */
		function getEventDispatcher():IEventDispatcher;
		
		/**
		 * Retrieves the data of the <code>loadManagerObject</code> if the loading
		 * is complete. If the <code>loadManagerObject</code> is a <code>URLoader</code>
		 * object, then the <code>data</code> value is returned else the <code>loadManagerObject</code>
		 * itself is returned.
		 * 
		 * @return	The data of the <code>loadManagerObject</code>.
		 */
		function getData():*;
		
		/**
		 * Retrieves the type of the file based on the <code>LoadableFileType</code> constants.
		 * 
		 * @return	The <code>ILoadableFile</code> type.
		 * @see		ch.capi.net.LoadableFileType	LoadableFileType
		 */
		function getType():String;
	}
}