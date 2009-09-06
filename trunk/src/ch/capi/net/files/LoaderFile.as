package ch.capi.net.files
{
	import flash.display.BitmapData;	
	import flash.display.Bitmap;	
	import flash.net.URLRequest;	
	import flash.system.ApplicationDomain;	
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.events.IEventDispatcher;
	
	import ch.capi.net.DataType;	
	import ch.capi.net.LoadableFileType;	
	import ch.capi.net.ILoadableFile;

	/**
	 * Represents a <code>ILoadableFile</code> based on a <code>Loader</code> object.
	 * 
	 * @see		ch.capi.display.IRootDocument	IRootDocument
	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0
	 */
	public class LoaderFile extends AbstractLoadableFile implements ILoadableFile
	{
		//---------//
		//Variables//
		//---------//
		
		/**
		 * Defines the <code>LoaderContext</code> of the
		 * <code>Loader</code> object.
		 */
		public var loaderContext:LoaderContext 		= null; //initialized by LoadableFileFactory
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>LoaderFile</code> object.
		 * 
		 * @param	loadObject		The <code>URLLoader</code> object.
		 */
		public function LoaderFile(loadObject:Loader):void
		{
			super(loadObject);
			
			var dispatcher:IEventDispatcher = getEventDispatcher();
			registerTo(dispatcher);
		}
		
		//--------------//
		//Public methods//
		//--------------// 
		
		/**
		 * Retrieves the <code>contentLoaderInfo</code> of the <code>Loader</code>.
		 * 
		 * @return	The <code>LoaderInfo</code> object.
		 */
		public function getEventDispatcher():IEventDispatcher
		{
			checkDestroyed();
			return (loadManagerObject as Loader).contentLoaderInfo;
		}
		
		/**
		 * Retrieves the data of the <code>loadManagerObject</code> if the loading
		 * is complete. The supported classes are <code>DataType.LOADER</code>, <code>DataType.BITMAP</code>
		 * and <code>DataType.BITMAP_DATA</code>. If the <code>asClass</code> parameter is <code>null</code>,
		 * then the source <code>Loader</code> object is returned.
		 * 
		 * @param 	asClass		The class instance that should be returned by the method.
		 * @param	appDomain	The <code>ApplicationDomain</code> to retrieve the class. If <code>null</code> is specified, then
		 * 						the current domain will be used.
		 * @return	An instance of the specified class containing the data of the <code>loadManagerObject</code>.
		 * @throws	ArgumentError	If the class type is not supported.
		 * @throws	ch.capi.errors.DataError		If the data are not loaded.
		 * 
		 * @see		#isClassSupported()		isClassSupported()
		 * @see		ch.capi.net.DataType	DataType
		 */
		public function getData(asClass:String=null, appDomain:ApplicationDomain=null):*
		{
			checkDestroyed();
			checkData();
			if (asClass != null && !isClassSupported(asClass, appDomain)) throw new ArgumentError("The type '"+asClass+"' is not supported");	
			
			//simply returns the Loader
			if (asClass == null || asClass == DataType.LOADER) return (loadManagerObject as Loader);
			if (appDomain == null) appDomain = ApplicationDomain.currentDomain;
			
			//checks the content
			if (! (loadManagerObject.content is Bitmap)) throw new ArgumentError("The type '"+asClass+"' cannot be supported, because the "+
																					 "content is not a Bitmap : "+this);
			
			//creates a new detached bitmap
			var sourceBitmap:Bitmap = loadManagerObject.content as Bitmap;
			var clonedBitmapData:BitmapData = sourceBitmap.bitmapData.clone();
			
			//simply returns the cloned BitmapData if needed
			if (asClass == DataType.BITMAP_DATA) return clonedBitmapData;
			
			var bmpClass:Class = appDomain.getDefinition(asClass) as Class;
			return new bmpClass(clonedBitmapData);
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
			return isInstanceOfClass(aClass, DataType.BITMAP, appDomain) 
				   || aClass == DataType.LOADER 
				   || aClass == DataType.BITMAP_DATA;
		}
		
		/**
		 * Retrieves the type of the file. This method always return <code>LoadableFileType.SWF</code>.
		 * 
		 * @return	The <code>ILoadableFile</code> type.
		 */
		public function getType():String
		{
			return LoadableFileType.SWF;
		}
		
		/**
		 * Destroys this <code>LoaderFile</code>. This will call the <code>unload()</code> method on the <code>Loader</code>.
		 * If you're using the FP10, then this method will call the <code>unloadAndStop(true)</code> method.
		 */
		public override function destroy():void
		{
			//those namespaces/variables are defined at compile-time
			MASAPI::PLAYER_FP9
			{
				(loadManagerObject as Loader).unload();
			}
			
			MASAPI::PLAYER_FP10
			{
				(loadManagerObject as Loader).unloadAndStop(true);
			}
			
			loaderContext = null;
			super.destroy();
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//

		/**
		 * Starts the loading of the <code>Loader</code>.
		 */
		protected override function processLoading(request:URLRequest):void
		{
			var ul:Loader = loadManagerObject as Loader;
			ul.load(request, loaderContext);
		}
	}
}