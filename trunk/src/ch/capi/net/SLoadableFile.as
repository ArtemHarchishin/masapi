package ch.capi.net
{
	import flash.events.IEventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	import ch.capi.net.LoadableFileType;
	
	/**
	 * Represents a <code>ILoadableFile</code> based on a <code>Sound</code> object.
	 * 
	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0
	 */
	internal class SLoadableFile extends AbstractLoadableFile implements ILoadableFile
	{
		//---------//
		//Variables//
		//---------//
		
		/**
		 * Defines the <code>SoundLoaderContext</code> to be used
		 * within the loaded <code>Sound</code>.
		 */
		public var soundLoaderContext:SoundLoaderContext = new SoundLoaderContext();
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>SLoadableFile</code> object.
		 * 
		 * @param	snd		The <code>Sound</code> object.
		 */
		public function SLoadableFile(snd:Sound):void
		{
			super(snd);
			
			registerTo(snd);	
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
			var sd:Sound = loadManagerObject as Sound;
			sd.load(re, soundLoaderContext);
		}
		
		/**
		 * Stops the loading of the data.
		 */
		public override function stop():void
		{
			super.stop();
			
			var sd:Sound = loadManagerObject as Sound;
			sd.close();
			
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
			return loadManagerObject as Sound;
		}
		
		/**
		 * Retreives the data of the <code>loadManagerObject</code> if the loading
		 * is complete.
		 * 
		 * @return	The data of the <code>loadManagerObject</code>.
		 */
		public function getData():*
		{
			return loadManagerObject as Sound;
		}
		
		/**
		 * Retrieves the type of the file based on the <code>LoadableFileType</code> constants.
		 * 
		 * @return	The <code>ILoadableFile</code> type.
		 */
		public function getType():String
		{
			return LoadableFileType.SOUND;
		}
	}
}