package ch.capi.net
{
	import flash.net.URLRequest;	
	import flash.system.ApplicationDomain;	
	import flash.events.IEventDispatcher;
	import flash.net.URLStream;
	
	import ch.capi.net.LoadableFileType;
	
	/**
	 * Represents a <code>ILoadableFile</code> based on a <code>URLStream</code> object.
	 * 
	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0
	 */
	internal class RLoadableFile extends AbstractLoadableFile implements ILoadableFile
	{
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>RLoadableFile</code> object.
		 * 
		 * @param	loadObject		The <code>URLLoader</code> object.
		 */
		public function RLoadableFile(loadObject:URLStream):void
		{
			super(loadObject);
			
			registerTo(loadObject);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Retrieves the <code>IEventDispatcher</code> of all the sub-events
		 * of a <code>ILoadableFile</code>. For example, the source event dispatcher
		 * of a <code>Loader</code> object will be his <code>contentLoaderInfo</code>.
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
		 * is complete. If the asType parameter is specified, then the <code>ILoadableFile</code>
		 * will try to create an instance of it and parse the content into it.
		 * 
		 * @param 	asClass		The class instance that should be returned by the method.
		 * @param	appDomain	The <code>ApplicationDomain</code> to retrieve the class. If <code>null</code> is specified, then
		 * 						the current domain will be used.
		 * @return	The data of the <code>loadManagerObject</code>.
		 * @throws	ArgumentError	If the class type is not supported.
		 * 
		 * @see		#isClassSupported()		isClassSupported()
		 */
		public function getData(asClass:String=null, appDomain:ApplicationDomain= null):*
		{
			checkDestroyed();
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
			return aClass == "flash.net.URLStream";
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