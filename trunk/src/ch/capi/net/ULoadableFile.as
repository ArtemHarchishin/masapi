package ch.capi.net
{
	import flash.display.LoaderInfo;	
	
	import ch.capi.display.IRootDocument;	
	
	import flash.display.DisplayObject;	
	import flash.events.Event;	
	import flash.system.ApplicationDomain;	
	import flash.text.StyleSheet;	
	import flash.xml.XMLDocument;	
	import flash.net.URLVariables;	
	import flash.display.Loader;	
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * Represents a <code>ILoadableFile</code> based on a <code>URLLoader</code> object.
	 * 
	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0
	 */
	internal class ULoadableFile extends AbstractLoadableFile implements ILoadableFile
	{
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ULoadableFile</code> object.
		 * 
		 * @param	loadObject		The <code>URLLoader</code> object.
		 */
		public function ULoadableFile(loadObject:URLLoader):void
		{
			super(loadObject);
			
			registerTo(loadObject);
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
			var ul:URLLoader = loadManagerObject as URLLoader;
			ul.load(re);
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
			return loadManagerObject as URLLoader;
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
		public function getData(asClass:String=null, appDomain:ApplicationDomain = null):*
		{
			checkDestroyed();
			if (asClass == null) return loadManagerObject.data;
			if (appDomain == null) appDomain = ApplicationDomain.currentDomain;
			if (!isClassSupported(asClass, appDomain)) throw new ArgumentError("The type '"+asClass+"' is not supported for this kind of data ("+getType()+")");
			
			if (asClass == "flash.utils.ByteArray") return loadManagerObject.data;
			if (asClass == "XML") return new XML(loadManagerObject.data);
			
			//create the instance
			var srcClass:Class = appDomain.getDefinition(asClass) as Class;
			var insClass:* = new srcClass();
			
			//create the data
			var loadedData:* = loadManagerObject.data;
			if (insClass is Loader){ insClass.contentLoaderInfo.addEventListener(Event.INIT, onInit, false, 10, true); insClass.loadBytes(loadedData); }
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
			if (getType() == LoadableFileType.BINARY && (aClass == "flash.utils.ByteArray" ||
														 isInstanceOfClass(aClass, "flash.display.Loader", appDomain))) return true;
			if (getType() == LoadableFileType.VARIABLES && isInstanceOfClass(aClass, "flash.net.URLVariables", appDomain)) return true;
			
			//get a text data
			if (isInstanceOf(aClass, ["XML",
									  "flash.xml.XMLDocument",
									  "flash.text.StyleSheet",
									  "flash.net.URLVariables"], appDomain)) return true;
			
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
			 * there would be conceptually wrong that this ILoadableFile dispatches a Event.INIT event !
			 */
		}
	}
}