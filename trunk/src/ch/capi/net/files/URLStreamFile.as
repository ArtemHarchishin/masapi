package ch.capi.net.files
{
	import flash.net.URLRequest;	
	import flash.system.ApplicationDomain;	
	import flash.events.IEventDispatcher;
	import flash.net.URLStream;
	
	import ch.capi.net.LoadableFileType;
	import ch.capi.net.DataType;	
	import ch.capi.net.ILoadableFile;	
	
	/**
	 * Represents a <code>ILoadableFile</code> based on a <code>URLStream</code> object.
	 * 
	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0
	 */
	public class URLStreamFile extends AbstractLoadableFile implements ILoadableFile
	{
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>URLStreamFile</code> object.
		 * 
		 * @param	loadObject		The <code>URLStream</code> object.
		 */
		public function URLStreamFile(loadObject:URLStream):void
		{
			super(loadObject);
			
			registerTo(loadObject);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Retrieves the <code>IEventDispatcher</code>, which is directly the
		 * <code>URLStream</code> object.
		 * 
		 * @return	The <code>URLStream</code> object.
		 */
		public function getEventDispatcher():IEventDispatcher
		{
			checkDestroyed();
			return loadManagerObject as URLStream;
		}
		
		/**
		 * Retrieves the data of the <code>loadManagerObject</code> if the loading
		 * is complete. Actually, the only class supported is <code>DataType.STREAM</code>.
		 * 
		 * @param 	asClass		The class instance that should be returned by the method.
		 * @param	appDomain	The <code>ApplicationDomain</code> to retrieve the class. If <code>null</code> is specified, then
		 * 						the current domain will be used.
		 * @return	The data of the <code>loadManagerObject</code>.
		 * @throws	ArgumentError	If the class type is not supported.
		 * @throws	ch.capi.errors.DataError		If the data are not loaded.
		 * 
		 * @see		#isClassSupported()		isClassSupported()
		 */
		public function getData(asClass:String=null, appDomain:ApplicationDomain= null):*
		{
			checkDestroyed();
			checkData();
			if (asClass != null && !isClassSupported(asClass)) throw new ArgumentError("The type '"+asClass+"' is not supported");
			return (loadManagerObject as URLStream);
		}
		
		/**
		 * Retrieves if the specified class type is supported by this <code>ILoadableFile</code> or not.
		 * 
		 * @param	type	The class type to check.
		 * @param	appDomain	The <code>ApplicationDomain</code> to retrieve the class. If <code>null</code> is specified, then
		 * 						the current domain will be used.
		 * @return	<code>true</code> if the type is supported.
		 */
		public function isClassSupported(aClass:String, appDomain:ApplicationDomain=null):Boolean
		{
			return aClass == DataType.STREAM;
		}
		
		/**
		 * Retrieves the type of the file based on the <code>LoadableFileType</code> constants.
		 * 
		 * @return	The <code>ILoadableFile</code> type.
		 */
		public function getType():String
		{
			return LoadableFileType.STREAM;
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Starts the loading of the <code>URLStream</code>.
		 */
		protected override function processLoading(request:URLRequest):void
		{
			var ul:URLStream = loadManagerObject as URLStream;
			ul.load(request);
		}
	}
}