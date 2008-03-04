package ch.capi.net 
{	import ch.capi.net.MassLoader;
	import ch.capi.data.tree.ArrayHeap;
	import ch.capi.net.ILoadableFile;
	import ch.capi.events.PriorityEvent;
	import ch.capi.net.IMassLoader;
	import ch.capi.data.IMap;
	import ch.capi.data.DictionnaryMap;
	import ch.capi.net.ILoadManager;
	
	/**
	 * Dispatched when the loading of files with a lower priority starts. This event
	 * won't be dispatched if the value of <code>loadByPriority</code> is <code>false</code>.
	 * 
	 * @see			ch.capi.net.PriorityMassLoader#loadByPriority	loadByPriority
	 * @eventType	ch.capi.events.PriorityEvent.PRIORITY_CHANGED
	 */
	[Event(name="priorityChanged", type="ch.capi.events.PriorityEvent")]
	
	/**
	 * Manages the massive loading of the files by priority. The files with the highest priority will be loaded first.
	 * By default, all the files with the higher priority will be loaded before the files with a lower priority will
	 * start being loaded (<code>loadByPriority</code> value).
	 * <p>To sort the files by priority, the <code>PriorityMassLoader</code> will use a <code>ArrayHeap</code> object as
	 * <code>filesQueue</code> data structure.</p>
	 * 
	 * @example
	 * <listing version="3.0">
	 * var lf:LoadableFileFactory = new LoadableFileFactory();
	 * var file1:ILoadableFile = lf.create("myFile.txt");
	 * var file2:ILoadableFile = lf.create("myAnim.swf");
	 * var file3:ILoadableFile = lf.create("otherFile.xml");
	 * 
	 * var ml:PriorityMassLoader = new PriorityMassLoader();
	 * ml.addPriorizedFile(file1, 15);
	 * ml.addPriorizedFile(file2, 15);
	 * ml.addFile(file3); //priority of 0 by default
	 * 
	 * var eventFile:Function = function(evt:MassLoadEvent):void
	 * {
	 *    var src:ILoadableFile = (evt.file as ILoadableFile);
	 *    trace(evt.type+" => "+src.urlRequest.url);
	 * }
	 * ml.addEventListener(MassLoadEvent.FILE_OPEN, eventFile);
	 * ml.addEventListener(MassLoadEvent.FILE_CLOSE, eventFile);
	 * 
	 * ml.start();
	 * </listing>
	 * 
	 * @see		ch.capi.data.tree.ArrayHeap		ArrayHeap	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public class PriorityMassLoader extends MassLoader implements IMassLoader
	{
		//---------//
		//Constants//
		//---------//
		
		//---------//
		//Variables//
		//---------//
		private var _filePriority:IMap			= new DictionnaryMap(false);
		private var _currentPriority:int		= 0;
		
		/**
		 * Defines the default priority to use for the <code>addFile</code> method.
		 * 
		 * @see	#addFile()		addFile()
		 */
		public var defaultPriority:int			= 0;

		/**
		 * Defines if the loading is done by priority. If this value is <code>false</code> then the files
		 * will be loaded directly into the priority order but will not take care of the change of the priority.
		 * If this value is <code>true</code>, then the <code>parallelFiles</code> value will not be used.
		 */
		public var loadByPriority:Boolean		= true;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the current priority of the files that are being loaded.
		 */
		public function get currentPriority():int { return _currentPriority; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>PriorityMassLoader</code> object.
		 */
		public function PriorityMassLoader():void
		{
			filesQueue = new ArrayHeap(sortFiles);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Add the specified file into the loading queue with the specified
		 * <code>defaultPriority</code>. To specify the file priority manually,
		 * use the <code>addPriorizedFile</code> method.
		 * 
		 * @param	file	The <code>ILoadManager</code>.
		 * @see		#defaultPriority	defaultPriority
		 * @see		#addPriorizedFile()	addPriorizedFile()
		 */
		public override function addFile(file:ILoadManager):void
		{
			addPrioritizedFile(file, defaultPriority);
		}
		
		/**
		 * Removes the specified file from the loading queue.
		 * 
		 * @param	file	The <code>ILoadManager</code>.
		 */
		public override function removeFile(file:ILoadManager):void
		{
			super.removeFile(file);
			
			_filePriority.remove(file);
		}
	
		/**
		 * Add a file with a specific priority into the loading queue.
		 * 
		 * @param	file		The <code>ILoadManager</code>.
		 * @param	priority	The priority of the file.
		 */
		public function addPrioritizedFile(file:ILoadManager, priority:int=0):void
		{
			super.addFile(file);
			
			_filePriority.put(file, priority);
		}
		
		/**
		 * Retreives the priority of a <code>ILoadManager</code> object. In order to change the
		 * priority of a file, simple remove it and readd it using the <code>addPriorizedFile</code>
		 * method.
		 * 
		 * @param	file		The file to get the priority.
		 * @return	The priority or 0 if the file isn't into the loading queue.
		 * @see		#removeFile()		removeFile()
		 * @see		#addPriorizedFile()	addPriorizedFile()
		 */
		public function getFilePriority(file:ILoadManager):int
		{
			return _filePriority.getValue(file) as int;	
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Determines which file must be loaded first. This method will return 0 if one of both
		 * arguments is not a <code>ILoadableFile</code>, otherwise it retrieves the priority value
		 * from the properties and compare them.
		 * 
		 * @param	a		A <code>ILoadManager</code>.
		 * @param	b		A <code>ILoadManager</code>.
		 * @return	An <code>int</code> greater than 0 if <code>b</code> must be loaded before <code>a</code>.
		 * @see		ch.capi.data.tree.IHeap#sortFunction	IHeap.sortFunction
		 * @see		#getFilePriority()			getFilePriority()
		 */
		protected function sortFiles(a:ILoadManager, b:ILoadManager):int
		{
			if (!(a is ILoadableFile) || !(b is ILoadableFile)) return 0; //no comparison possible
			
			var al:ILoadableFile = a as ILoadableFile;
			var bl:ILoadableFile = b as ILoadableFile;

			var ad:int = getFilePriority(al);
			var bd:int = getFilePriority(bl);
			
			return bd - ad;
		}
		
		/**
		 * Start the loading of the files.
		 * <p>If the <code>loadByPriority</code> value is <code>true</code>,
		 * then, the method will retrieves the next file, checks his priority and start the loading of all
		 * the files with the same one. In that case, a <code>PriorityEvent.PRIORITY_CHANGED</code> event
		 * will be dispatched. If the <code>loadByPriority</code> value is <code>false</code>, it will
		 * retrieves the files by priority and start the loading of the value specified into the <code>parallelFiles</code>
		 * property.</p>
		 * <p>If there is file currently being loaded or the <code>filesQueue</code> is empty, this method does
		 * nothing.</p>
		 * 
		 * @see		ch.capi.net.MassLoader#parallelFiles		MassLoader.parallelFiles
		 */
		protected override function startLoading():void
		{
			//nothing to do
			if (numFilesLoading > 0 || filesQueue.isEmpty()) return;
			
			//use the old way for the loading
			if (!loadByPriority) { super.startLoading(); return; }
		
			//defines the next priority
			var ne:ILoadManager = super.nextFileToLoad;
			if (ne is ILoadableFile)
			{
				var ni:ILoadableFile = ne as ILoadableFile;
				_currentPriority = getFilePriority(ni);
			}
			
			//dispatch the priority event
			var evt:PriorityEvent = new PriorityEvent(PriorityEvent.PRIORITY_CHANGED, _currentPriority);
			dispatchEvent(evt);
			
			//start the loading of all the files with the new priority
			do
			{
				ne = super.nextFileToLoad;
				if (ne is ILoadableFile)
				{
					var ai:ILoadableFile = ne as ILoadableFile;
					var cr:int = getFilePriority(ai);
					
					//the file has a lower priority
					if (cr != _currentPriority) break;
				}
				
				if (loadNextFile() == null && isComplete()) break;
			}
			while(!filesQueue.isEmpty());		}
	}}