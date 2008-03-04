package ch.capi.net
{
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
		 * Stops the loading of the data.
		 */
		public override function stop():void
		{
			super.stop();
			
			var ul:URLLoader = loadManagerObject as URLLoader;
			ul.close();
			
			super.close();
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
		 * Retreives the data of the <code>loadManagerObject</code> if the loading
		 * is complete.
		 * 
		 * @return	The data of the <code>loadManagerObject</code>.
		 */
		public function getData():*
		{
			return (loadManagerObject as URLLoader).data;
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