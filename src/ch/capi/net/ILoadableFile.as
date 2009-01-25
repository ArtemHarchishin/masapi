package ch.capi.net
{
	import flash.system.ApplicationDomain;	
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
	 * Dispatched when the http headers are received. This event isn't sent by the all the load manager objects.
	 * 
	 * @eventType	flash.events.HTTPStatusEvent.HTTP_STATUS
	 */
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
	
	/**
	 * Dispatched when the content of the <code>loadManagerObject</code> is displayed. This event is only dispatched if the
	 * type of <code>ILoadableFile</code> is <code>LoadableFileType.SWF</code>.
	 * 
	 * @eventType	flash.events.Event.INIT
	 */
	[Event(name="init", type="flash.events.Event")]
	
	/**
	 * Represents a loadable file.
	 * 
	 * @see			ch.capi.net.AbstractLoadableFile	AbstractLoadableFile
	 * @see			ch.capi.net.LoadableFileFactory		LoadableFileFactory
	 * @see			ch.capi.net.LoadableFileType		LoadableFileType
	 * @see			ch.capi.net.FileTypeSelector		FileTypeSelector
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
		 * Defines the variables key/values to be replaced
		 * into the url before the loading is launched.
		 * 
		 * @see	ch.capi.net.LoadableFileFactory#defaultVariables		LoadableFileFactory.defaultVariables
		 * @see	ch.capi.utils.VariableReplacer#defaultVariableRegexp	VariableReplacer.defaultVariableRegexp
		 */
		function get urlVariables():IMap;
		function set urlVariables(value:IMap):void;
		
		/**
		 * Defines the <code>URLRequest</code> that will be loaded by the <code>ILoadableFile</code>. This
		 * <code>URLRequest</code> has no more variables. If for some reason you need to modify the fixed
		 * request before starting the loading you should call the <code>prepareFixedRequest()</code> before,
		 * otherwise all your changes will be lost.
		 * 
		 * @see	#invalidateFixedRequest()	invalidateFixedRequest()
		 * @see	#prepareFixedRequest()		prepareFixedRequest()
		 */
		function get fixedRequest():URLRequest;
		
		/**
		 * Defines if the <code>ILoadableFile</code> can use the cache or not.
		 */
		function get useCache():Boolean;
		function set useCache(value:Boolean):void;
		
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
		 * Defines the load manager object. This object represents the object that
		 * manages the loading, i.e. a <code>Loader</code>, <code>URLLoader</code>, 
		 * <code>Sound</code>, ...
		 */
		function get loadManagerObject():Object;
		
		/**
		 * Invalidate the current <code>fixedRequest</code>. It means that the next time
		 * the <code>start()</code> method will be launched, the <code>ILoadableFile</code>
		 * will relaunch the loading of the data, without taking care of the cache.
		 * 
		 * @see	#fixedRequest	fixedRequest
		 * @see	#prepareFixedRequest()	prepareFixedRequest()
		 */
		function invalidateFixedRequest():void;
		
		/**
		 * Tells the <code>ILoadableFile</code> to update the <code>fixedRequest</code> value that
		 * will be used to load the file.
		 * 
		 * @see		#fixedRequest				fixedRequest
		 * @see		#invalidateFixedRequest()	invalidateFixedRequest
		 */
		function prepareFixedRequest():void;
		
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
		 * is complete. If the asClass parameter is specified, then the <code>ILoadableFile</code>
		 * will try to create an instance of it and parse the content into it.
		 * 
		 * @param 	asClass		The class instance that should be returned by the method.
		 * @param	appDomain	The <code>ApplicationDomain</code> to retrieve the class. If <code>null</code> is specified, then
		 * 						the current domain will be used.
		 * @return	The data of the <code>loadManagerObject</code>.
		 * @throws	ArgumentError	If the class type is not supported.
		 * 
		 * @see		ch.capi.net.DataType	DataType class
		 * @see		#isClassSupported()		isClassSupported()
		 */
		function getData(asClass:String=null, appDomain:ApplicationDomain=null):*;

		/**
		 * Retrieves if the specified class type is supported by this <code>ILoadableFile</code> or not.
		 * 
		 * @param	type	The class type to check.
		 * @param	appDomain	The <code>ApplicationDomain</code> to retrieve the class. If <code>null</code> is specified, then
		 * 						the current domain will be used.
		 * @return	<code>true</code> if the type is supported.
		 * @see		ch.capi.net.DataType	DataType class
		 */
		function isClassSupported(aClass:String, appDomain:ApplicationDomain=null):Boolean;
		
		/**
		 * Retrieves the type of the file based on the <code>LoadableFileType</code> constants.
		 * 
		 * @return	The <code>ILoadableFile</code> type.
		 * @see		ch.capi.net.LoadableFileType	LoadableFileType
		 */
		function getType():String;
		
		/**
		 * Retrieves if this <code>ILoadableFile</code> has been destroyed. If this method returns <code>true</code>, then
		 * no more operation is available on the <code>ILoadableFile</code>.
		 * 
		 * @return	<code>true</code> if the file has been destroyed.
		 */
		function isDestroyed():Boolean;
		
		/**
		 * Destroys this <code>ILoadableFile</code>. This method causes to set the <code>loadManagerObject</code> value to
		 * <code>null</code> and releases all other references to the content loaded contained into the current <code>ILoadableFile</code>.
		 * After calling this method, no more operation is available on the <code>ILoadableFile</code> instance.
		 */
		function destroy():void;
	}
}