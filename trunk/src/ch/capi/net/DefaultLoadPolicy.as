package ch.capi.net 
{
	import ch.capi.data.DictionnaryMap;	
	import ch.capi.data.IMap;	
	
	import flash.events.Event;	
	
	/**
	 * Basic implementation of a <code>ILoadPolicy</code>. This class manages the number of a file must
	 * be reloaded if its download fails.
	 * <p>The <code>DefaultLoadPolicy</code> uses weak references to store the files in order to know how
	 * many times the files have been reloaded.</p>
	 * 
	 * @example
	 * <listing version="3.0">
	 * var lp:DefaultLoadPolicy = new DefaultLoadPolicy(2);
	 * var ml:MassLoader = new MassLoader(0, true, lp);
	 * 
	 * //...
	 * 
	 * ml.start();
	 * </listing>
	 * 
	 * 
	 * @author 		Cedric Tabin
	 * @version		1.0
	 */
	public class DefaultLoadPolicy implements ILoadPolicy
	{
		//---------//
		//Variables//
		//---------//
		private var _linkedFiles:IMap 		= new DictionnaryMap(true);
		private var _defaultFiles:IMap 		= new DictionnaryMap(true);

		/**
		 * Defines how many times a file must be reloaded if its download fails. 0 means that
		 * the file will be reloaded since it is successfully loaded.
		 */
		public var reloadTimes:uint;

		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the <code>IMap</code> that links the loaded files within a default file to load
		 * if the specified file failed. Note that this <code>IMap</code> uses weak references.
		 * 
		 * @example
		 * <listing version="3.0">
		 * var lp:DefaultLoadPolicy = new DefaultLoadPolicy(2);
		 * var ml:MassLoader = new MassLoader(0, true, lp);
		 * 
		 * var factory:LoadableFileFactory = new LoadableFileFactory();
		 * var baseFile:ILoadableFile = factory.create("foo.xml");
		 * var defaultFile:ILoadableFile = factory.create("fooDefault.xml");
		 * 
		 * lp.defaultFiles.put(baseFile, defaultFile);
		 * 
		 * ml.addFile(baseFile);
		 * ml.start();
		 * </listing>
		 */
		public function get defaultFiles():IMap { return _defaultFiles; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>DefaultLoadPolicy</code> object.
		 * 
		 * @param	reloadTimes		Defines how many times a file must be reloaded if its download fails. 0 means that
		 * 							the file will be reloaded since it is successfully loaded.
		 */
		public function DefaultLoadPolicy(reloadTimes:int=3):void
		{
			this.reloadTimes = reloadTimes;
		}

		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Called by the <code>MassLoader</code> when a file download is complete. This can be due
		 * to a successful download or not (see the <code>closeEvent</code> parameters).
		 * 
		 * @param	file			The <code>ILoadManager</code> to process.
		 * @param	closeEvent 		The event within the <code>ILoadManager</code> is finished.
		 * @return	The <code>ILoadManager</code> to reload or <code>null</code> if there is nothing do.
		 */
		public function processFile(file:ILoadManager, closeEvent:Event):ILoadManager
		{
			//nothing to process
			if (closeEvent.type == Event.COMPLETE) return null;
			
			var nbLoaded:int = getFileLoadedTimes(file);
			if (nbLoaded >= reloadTimes)
			{
				if (defaultFiles.containsKey(file)) return defaultFiles.getValue(file);
				else if (reloadTimes > 0) return null; //if the reloadTimes is 0, then load the files again & again...
			}
			
			_linkedFiles.put(file, nbLoaded+1);
			return file;
		}

		/**
		 * Retrieves how many times a file has been loaded.
		 * 
		 * @param	file		The <code>ILoadManager</code>.
		 * @return	The number of times that the file has been loaded (starts from 1).
		 */
		public function getFileLoadedTimes(file:ILoadManager):uint
		{
			if (!_linkedFiles.containsKey(file)) return 1;
			
			return _linkedFiles.getValue(file);
		}
	}
}
