package ch.capi.net
{
	import flash.system.ApplicationDomain;	
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.net.URLRequest;
	import flash.events.IEventDispatcher;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import ch.capi.net.LoadableFileType;
	import ch.capi.display.IRootDocument;

	/**
	 * Represents a <code>ILoadableFile</code> based on a <code>Loader</code> object.
	 * 
	 * @see		ch.capi.display.IRootDocument	IRootDocument
	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0
	 */
	internal class LLoadableFile extends AbstractLoadableFile implements ILoadableFile
	{
		//---------//
		//Variables//
		//---------//
		
		/**
		 * Defines the <code>LoaderContext</code> of the
		 * <code>Loader</code> object.
		 */
		//public var loaderContext:LoaderContext 		= new LoaderContext(false, ApplicationDomain.currentDomain);
		public var loaderContext:LoaderContext 		= null; //initialized by LoadableFileFactory
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ULoadableFile</code> object.
		 * 
		 * @param	loadObject		The <code>URLLoader</code> object.
		 */
		public function LLoadableFile(loadObject:Loader):void
		{
			super(loadObject);
			
			var dispatcher:IEventDispatcher = getEventDispatcher();
			registerTo(dispatcher);
			dispatcher.addEventListener(Event.INIT, onInit, false, 10, true);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Starts the loading of the data.
		 */
		public override function start():void
		{
			super.start();
			
			var re:URLRequest = getURLRequest();
			var ul:Loader = loadManagerObject as Loader;
			ul.load(re, loaderContext);
		}
		
		/**
		 * Retrieves the <code>IEventDispatcher</code> of all the sub-events
		 * of a <code>ILoadableFile</code>. For example, the source event dispatcher
		 * of a <code>Loader</code> object will be his <code>contentLoaderInfo</code>.
		 * 
		 * @return	The <code>URLLoader</code> object.
		 */
		public function getEventDispatcher():IEventDispatcher
		{
			checkDestroyed();
			return (loadManagerObject as Loader).contentLoaderInfo;
		}
		
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
		 * @see		#isClassSupported()		isClassSupported()
		 */
		public function getData(asClass:String=null, appDomain:ApplicationDomain=null):*
		{
			checkDestroyed();
			if (asClass != null && !isClassSupported(asClass)) throw new ArgumentError("The type '"+asClass+"' is not supported");	
			return (loadManagerObject as Loader);
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
			return aClass == "flash.display.Loader";
		}
		
		/**
		 * Retrieves the type of the file based on the <code>LoadableFileType</code> constants.
		 * 
		 * @return	The <code>ILoadableFile</code> type.
		 */
		public function getType():String
		{
			return LoadableFileType.SWF;
		}
		
		/**
		 * Destroys this <code>ILoadableFile</code>. This method causes to set the <code>loadManagerObject</code> value to
		 * <code>null</code> and releases all other references to the content loaded contained into the current <code>ILoadableFile</code>.
		 * After calling this method, no more operation is available on the <code>ILoadableFile</code> instance.
		 */
		public override function destroy():void
		{
			(loadManagerObject as Loader).unload();
			loaderContext = null;
			super.destroy();
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//

		/**
		 * <code>Event.INIT</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected function onInit(evt:Event):void
		{
			var src:Loader = loadManagerObject as Loader;
			var cnt:DisplayObject = src.content;
			
			//set the linked loadable file
			if (cnt is IRootDocument)
			{
				var adc:IRootDocument = cnt as IRootDocument;
				adc.initializeContext(this);
			}
		}
	}
}