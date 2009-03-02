package ch.capi.net.files
{
	import flash.net.URLRequest;	
	import flash.system.ApplicationDomain;	
	import flash.events.IEventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	
	import ch.capi.net.LoadableFileType;
	import ch.capi.net.DataType;	
	import ch.capi.net.ILoadableFile;	
	
	/**
	 * Represents a <code>ILoadableFile</code> based on a <code>Sound</code> object.
	 * 
	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0
	 */
	public class SoundFile extends AbstractLoadableFile implements ILoadableFile
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
		 * Creates a new <code>SoundFile</code> object.
		 * 
		 * @param	snd		The <code>Sound</code> object.
		 */
		public function SoundFile(snd:Sound):void
		{
			super(snd);
			
			registerTo(snd);	
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Retrieves the <code>IEventDispatcher</code>, which is directly the <code>Sound</code> instance.
		 * 
		 * @return	The <code>Sound</code> object.
		 */
		public function getEventDispatcher():IEventDispatcher
		{
			checkDestroyed();
			return loadManagerObject as Sound;
		}
		
		/**
		 * Retrieves the data of the <code>loadManagerObject</code> if the loading
		 * is complete. Currently, the only type supported is <code>DataType.SOUND</code>.
		 * 
		 * @param 	asClass		The class instance that should be returned by the method.
		 * @param	appDomain	The <code>ApplicationDomain</code> to retrieve the class. If <code>null</code> is specified, then
		 * 						the current domain will be used.
		 * @return	The <code>Sound</code> object.
		 * @throws	ArgumentError	If the class type is not supported.
		 * 
		 * @see		#isClassSupported()		isClassSupported()
		 */
		public function getData(asClass:String=null, appDomain:ApplicationDomain= null):*
		{
			checkDestroyed();
			if (asClass != null && !isClassSupported(asClass)) throw new ArgumentError("The type '"+asClass+"' is not supported");
			return loadManagerObject as Sound;
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
			return aClass == DataType.SOUND;
		}
		
		/**
		 * Retrieves the type of the file. This method always returns <code>LoadableFileType.SOUND</code>.
		 * 
		 * @return	The <code>ILoadableFile</code> type.
		 */
		public function getType():String
		{
			return LoadableFileType.SOUND;
		}
		
		/**
		 * Destroys this <code>SoundFile</code>.
		 */
		public override function destroy():void
		{
			soundLoaderContext = null;
			super.destroy();
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Starts the loading of the <code>Sound</code>.
		 */
		protected override function processLoading(request:URLRequest):void
		{
			var sd:Sound = loadManagerObject as Sound;
			sd.load(request, soundLoaderContext);
		}
	}
}