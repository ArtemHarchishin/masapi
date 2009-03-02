package ch.capi.net.files
{	import flash.display.BitmapData;	
	import flash.display.Bitmap;	
	import flash.system.LoaderContext;	
	import flash.net.URLRequest;	
	import flash.display.LoaderInfo;	
	import flash.display.DisplayObject;	
	import flash.events.Event;	
	import flash.system.ApplicationDomain;	
	import flash.text.StyleSheet;	
	import flash.xml.XMLDocument;	
	import flash.net.URLVariables;	
	import flash.display.Loader;	
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;

	import ch.capi.display.IRootDocument;
	import ch.capi.net.LoadableFileType;
	import ch.capi.net.DataType;	
	import ch.capi.net.ILoadableFile;		

	/**
	 * Represents a <code>ILoadableFile</code> based on a <code>URLLoader</code> object.
	 * 
	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0
	 */
	public class URLLoaderFile extends AbstractLoadableFile implements ILoadableFile
	{
		//---------//
		//Variables//
		//---------//
		
		/**
		 * Defines the <code>LoaderContext</code> for binary files when their are retrieved
		 * as <code>Loader</code>.
		 */
		public var loaderContext:LoaderContext = null;
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>URLLoaderFile</code> object.
		 * 
		 * @param	loadObject		The <code>URLLoader</code> object.
		 */
		public function URLLoaderFile(loadObject:URLLoader):void
		{
			super(loadObject);
			
			registerTo(loadObject);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Retrieves the <code>IEventDispatcher</code>, which is directly the
		 * <code>URLLoader</code> object.
		 * 
		 * @return	The <code>URLLoader</code> object.
		 */
		public function getEventDispatcher():IEventDispatcher
		{
			checkDestroyed();
			return loadManagerObject as URLLoader;
		}
		
		/**
		 * Retrieves the data of the <code>loadManagerObject</code> if the loading
		 * is complete. Depending of the type of data, many classes are supported :
		 * <ul>
		 * 	<li>If the format is binary, then the classes <code>DataType.BYTE_ARRAY</code>, <code>DataType.BITMAP</code> 
		 * 	and <code>DataType.LOADER</code> are supported.</li>
		 * 	<li>If the format is variables, then the class <code>DatyType.URL_VARIABLES</code> is supported.</li>
		 * 	<li>If the format is text, then the classes <code>DatyType.XML</code>, <code>DatyType.XML_DOCUMENT</code>,
		 * 	<code>DatyType.STYLE_SHEET</code> and <code>DatyType.URL_VARIABLES</code> are supported.
		 * </ul>
		 * 
		 * @param 	asClass		The class instance that should be returned by the method.
		 * @param	appDomain	The <code>ApplicationDomain</code> to retrieve the class. If <code>null</code> is specified, then
		 * 						the current domain will be used.
		 * @return	The data of the <code>loadManagerObject</code>.
		 * @throws	ArgumentError	If the class type is not supported.
		 * 
		 * @see		#isClassSupported()		isClassSupported()
		 */
		public function getData(asClass:String=null, appDomain:ApplicationDomain = null):*
		{
			checkDestroyed();
			if (asClass == null) return loadManagerObject.data;
			if (appDomain == null) appDomain = ApplicationDomain.currentDomain;
			if (!isClassSupported(asClass, appDomain)) throw new ArgumentError("The type '"+asClass+"' is not supported for this kind of data ("+getType()+")");
			
			var loadedData:* = loadManagerObject.data;
			if (asClass == DataType.BYTE_ARRAY) return loadedData;
			if (asClass == DataType.XML) return new XML(loadedData);
			
			//bitmap creation (asynchronous)
			if (asClass == DataType.BITMAP)
			{
				var tmpBitmap:Bitmap = new Bitmap();
				var tmpLoader:Loader = new Loader();
				tmpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onDataLoaded);
				tmpLoader.loadBytes(loadedData);
				
				//initializes the bitmap
				function onDataLoaded(evt:Event):void
				{
					if (! (tmpLoader.content is Bitmap)) throw new Error("The content of the ByteArray seems not to be a picture : "+this);
					
					//clone the data and put them into the returned Bitmap
					var content:Bitmap = tmpLoader.content as Bitmap;
					var clonedData:BitmapData = content.bitmapData.clone();
					tmpBitmap.bitmapData = clonedData;
				}
				
				return tmpBitmap;
			}
			
			//create the instance
			var srcClass:Class = appDomain.getDefinition(asClass) as Class;
			var insClass:* = new srcClass();
			
			//create the data
			if (insClass is Loader){ insClass.contentLoaderInfo.addEventListener(Event.INIT, onInit, false, 10, true); insClass.loadBytes(loadedData, loaderContext); }
			else if (insClass is URLVariables){ insClass.decode(loadedData); }
			else if (insClass is XMLDocument){ insClass.ignoreWhite=true; insClass.parseXML(loadedData); }
			else if (insClass is StyleSheet){ insClass.parseCSS(loadedData); }
			
			return insClass;
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
			if (getType() == LoadableFileType.BINARY && (aClass == DataType.BYTE_ARRAY || aClass == DataType.BITMAP
														 || isInstanceOfClass(aClass, DataType.LOADER, appDomain))) return true;
			if (getType() == LoadableFileType.VARIABLES && isInstanceOfClass(aClass, DataType.URL_VARIABLES, appDomain)) return true;
			
			//get a text data
			if (isInstanceOf(aClass, [DataType.XML,
									  DataType.XML_DOCUMENT,
									  DataType.STYLE_SHEET,
									  DataType.URL_VARIABLES], appDomain)) return true;
			
			return false;
		}
		
		/**
		 * Retrieves the type of the file based on the <code>LoadableFileType</code> constants.
		 * 
		 * @return	The <code>ILoadableFile</code> type.
		 */
		public function getType():String
		{
			return (loadManagerObject as URLLoader).dataFormat;
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//

		/**
		 * Starts the loading of the <code>URLLoader</code>.
		 */
		protected override function processLoading(request:URLRequest):void
		{
			var ul:URLLoader = loadManagerObject as URLLoader;
			ul.load(request);
		}

		/**
		 * <code>Event.INIT</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected override function onInit(evt:Event):void
		{
			var src:LoaderInfo = evt.target as LoaderInfo;
			var cnt:DisplayObject = src.content;
			
			//set the linked loadable file
			if (cnt is IRootDocument)
			{
				var adc:IRootDocument = cnt as IRootDocument;
				adc.initializeContext(this);
			}
			
			/*
			 * DO NOT CALL THE SUPER onInit METHOD !!!
			 * This method is only called to retrieve the data with the getData() method, so
			 * there would be conceptually wrong that a ULoadableFile dispatches a Event.INIT event !
			 */
		}
	}
}