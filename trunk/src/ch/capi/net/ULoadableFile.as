package ch.capi.net
{
	import flash.text.StyleSheet;	
	import flash.xml.XMLDocument;	
	import flash.net.URLVariables;	
	import flash.display.Loader;	
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
import flash.utils.getDefinitionByName;	
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
			return loadManagerObject as URLLoader;
		}
		
		/**
		 * Retrieves the data of the <code>loadManagerObject</code> if the loading
		 * is complete. If the asType parameter is specified, then the <code>ILoadableFile</code>
		 * will try to create an instance of it and parse the content into it.
		 * 
		 * @param 	asClass	The class instance that should be returned by the method.
		 * @return	The data of the <code>loadManagerObject</code>.
		 * @throws	ArgumentError	If the class type is not supported.
		 * 
		 * @see		#isClassSupported()		isClassSupported()
		 */
		public function getData(asClass:String=null):*
		{
			if (asClass == null) return (loadManagerObject as URLLoader).data;
			if (!isClassSupported(asClass)) throw new ArgumentError("The type '"+asClass+"' is not supported for this kind of data ("+getType()+")");
			
			if (asClass == "XML") return new XML(loadManagerObject.data);
			
			//create the instance
			var srcClass:Class = getDefinitionByName(asClass) as Class;
			var insClass:* = new srcClass();
			
			//create the data
			var loadedData:* = loadManagerObject.data;
			if (insClass is Loader) insClass.loadBytes(loadedData);
			else if (insClass is URLVariables) insClass.decode(loadedData);
			else if (insClass is XMLDocument) insClass.parseXML(loadedData);
			else if (insClass is StyleSheet) insClass.parseCSS(loadedData);
			
			return insClass;
		}
		
		/**
		 * Retrieves if the specified class type is supported by this <code>ILoadableFile</code> or not.
		 * 
		 * @param	type	The class type to check.
		 * @return	<code>true</code> if the type is supported.
		 */
		public function isClassSupported(type:String):Boolean
		{
			if (getType() == LoadableFileType.BINARY && isInstanceOfClass(type, "flash.display.Loader")) return true;
			if (getType() == LoadableFileType.VARIABLES && isInstanceOfClass(type, "flash.net.URLVariables")) return true;
			
			//get a text data
			if (isInstanceOf(type, ["XML",
									"flash.xml.XMLDocument",
									"flash.text.StyleSheet",
									"flash.net.URLVariables"])) return true;
			
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
	}
}