package ch.capi.net 
{	import flash.errors.IllegalOperationError;	
	import flash.events.Event;	
	
	import ch.capi.events.MassLoadEvent;			import ch.capi.net.MassLoader;
	import ch.capi.data.tree.ArrayHeap;
	import ch.capi.events.PriorityEvent;
	import ch.capi.net.IMassLoader;
	import ch.capi.data.IMap;
	import ch.capi.data.DictionnaryMap;
	import ch.capi.net.ILoadManager;
	
	/**
	 * Dispatched when the loading of files with a lower priority starts. This event
	 * will be dispatched only if the value of <code>loadByPriority</code> is <code>true</code>.
	 * 
	 * @see			ch.capi.net.PriorityMassLoader#loadByPriority	loadByPriority
	 * @eventType	ch.capi.events.PriorityEvent.PRIORITY_CHANGED
	 */
	[Event(name="priorityChanged", type="ch.capi.events.PriorityEvent")]
	
	/**
	 * Manages the massive loading of the files by priority. The files with the highest priority will be loaded first.
	 * By default, all the files with the higher priority will be loaded before the files with a lower one start being 
	 * loaded (<code>loadByPriority</code> value).
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
	 *    trace(evt.type+" => "+src);
	 * }
	 * ml.addEventListener(MassLoadEvent.FILE_OPEN, eventFile);
	 * ml.addEventListener(MassLoadEvent.FILE_CLOSE, eventFile);
	 * 
	 * ml.start();
	 * </listing>
	 * 
	 * @see		ch.capi.net.CompositeMassLoader	CompositeMassLoader	 * @author	Cedric Tabin - thecaptain
	 * @version	2.0	 */	public class PriorityMassLoader extends MassLoader implements IMassLoader
	{
		//---------//
		//Constants//
		//---------//
		
		//---------//
		//Variables//
		//---------//
		private var _filePriority:IMap				= new DictionnaryMap(true);
		private var _currentPriority:int			= 0;
		private var _loadByPriority:Boolean			= false;
		/**
		 * Defines the default priority to use for the <code>addFile</code> method.
		 * 
		 * @see	#addFile()		addFile()
		 */
		public var defaultPriority:int				= 0;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the current priority of the files that are being loaded.
		 */
		public function get currentPriority():int { return _currentPriority; }
		
		/**
		 * Defines if the loading is done by priority. By default, this value is <code>false</code>.
		 * <p>If this value is <code>false</code> then the files
		 * will be loaded directly in the priority order but will not take care of the change of the priority.
		 * If this value is <code>true</code>, then the <code>parallelFiles</code> value will not be used.</p>
		 * <p>If this value is changed after some files have been added to the loading queue, the order won't be
		 * the same as they were added (data structure updated)</p>
		 * 
		 * @see	ch.capi.data.IDataStructure				IDataStructure
		 * @see	ch.capi.net.MassLoader#filesQueue		MassLoader.filesQueue
		 * @see ch.capi.net.MassLoader#parallelFiles	MassLoader.parallelFiles
		 */
		public function get loadByPriority():Boolean { return _loadByPriority; }
		public function set loadByPriority(value:Boolean):void { _loadByPriority = value; }

		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>PriorityMassLoader</code> object.
		 * 
		 * @param	prallelFiles		Defines how many file to load at the same time. This value will affect the loading only if the
		 * 								<code>loadByPriority</code> property is <code>false</code>.
		 * @param	loadByPriority		Defines if the <code>PriorityMassLoader</code> must load the files by priority. If this value is
		 * 								<code>true</code>, then the <code>parallelFiles</code> property will be ignored.
		 */
		public function PriorityMassLoader(parallelFiles:uint=0, loadByPriority:Boolean=false):void 
		{
			super(parallelFiles);
			super.filesQueue = new ArrayHeap(sortFiles);
			
			_loadByPriority = loadByPriority;
		}

		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Add the specified file in the loading queue with the default priority.
		 * 
		 * @param	file	The <code>ILoadManager</code>.
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
		 * Add a file with a specific priority in the loading queue.
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
		 * Retreives the priority of a <code>ILoadManager</code> object.
		 * 
		 * @param	file		The file to get the priority.
		 * @return	The priority or 0 if the file isn't in the loading queue.
		 * @see		#addPriorizedFile()	addPriorizedFile()
		 * @see		#setFilePriority()	setFilePriority()
		 */
		public function getFilePriority(file:ILoadManager):int
		{
			return _filePriority.getValue(file) as int;	
		}
		
		/**
		 * Set a file priority of a <code>ILoadManager</code> object. Note that changing the priority
		 * of a file if the <code>PriorityMassLoader</code> is already loading won't affect it.
		 * 
		 * @param	file		The file to set the priority.
		 * @param	priority	The new priority of the file.
		 * @throws	IllegalOperationError	If the file is not in the loading queue.
		 */
		public function setFilePriority(file:ILoadManager, priority:int):void
		{
			if (!hasFile(file)) throw new IllegalOperationError("The specified file "+file+" is not in the loading queue");
			_filePriority.put(file, priority);
		}

		/**
		 * Defines the files to be loaded at the specified priority.
		 * 
		 * @param	priority	The priority.
		 * @return	The files that will be loaded at the specified priority.
		 */
		public function getFilesAtPriority(priority:int):Array
		{
			var files:Array = new Array();
			
			var storedFiles:Array = _filePriority.keys();
			for each(var file:ILoadManager in storedFiles)
			{
				var filePriority:int = getFilePriority(file);
				if (filePriority == priority) files.push(file);
			}
			
			return files;
		}

		/**
		 * Clear the loading queues and files priorities.
		 */
		override public function clear():void
		{
			super.clear();
			
			_filePriority.clear();
		}

		/**
		 * Lists all the files contained in this <code>PriorityMassLoader</code> in a <code>String</code>.
		 * 
		 * @return A <code>String</code> containing all the files.
		 */
		public override function toString():String
		{
			var data:String = "PriorityMassLoader[\n";
			var files:Array = super.getFiles();
			
			if (files.length > 0)
			{
				for (var i:int=0 ; i<files.length-1 ; i++)
				{
					var file:ILoadManager = files[i];
					var priority:int = getFilePriority(file);
					data += "  "+file+"("+priority+")\n";
				}
				
				var lastFile:ILoadManager = files[files.length-1];
				var lastPriority:int = getFilePriority(lastFile);
				data += "  "+lastFile+"("+lastPriority+")\n";
			}
			
			data += "]";
			
			return data;
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
			if (!(a is ILoadManager) || !(b is ILoadManager)) return 0; //no comparison possible
			
			var al:ILoadManager = a as ILoadManager;
			var bl:ILoadManager = b as ILoadManager;

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
		 * retrieves the files by priority and start the loading of the value specified in the <code>parallelFiles</code>
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
			_currentPriority = getFilePriority(ne);
			
			//dispatch the priority event
			var filesByPriority:Array = getFilesAtPriority(_currentPriority);
			var evt:PriorityEvent = new PriorityEvent(PriorityEvent.PRIORITY_CHANGED, _currentPriority, filesByPriority);
			dispatchEvent(evt);
			
			//start the loading of all the files with the new priority
			do
			{
				ne = super.nextFileToLoad;
				var cr:int = getFilePriority(ne);
					
				//the file has a lower priority
				if (cr != _currentPriority) break;
				
				//no more file to download and loading complete
				if (loadNextFile() == null && isComplete()) break;
			}
			while(!filesQueue.isEmpty());		}
		
		/**
		 * Creates a <code>MassLoadEvent</code> based on the specified <code>ILoadManager</code>. This method also add
		 * the priority to the <code>MassLoadEvent</code>.
		 * 
		 * @param	file	The <code>ILoadManager</code>.
		 * @param	type	The <code>MassLoadEvent</code> type. This value can be <code>MassLoadEvent.FILE_OPEN</code>
		 * 					or <code>MassLoadEvent.FILE_CLOSE</code>.
		 * @param	evt		The close event, if any.
		 * @return	The created <code>MassLoadEvent</code>.
		 */
		protected override function createMassLoadEvent(file:ILoadManager, type:String, evt:Event = null):MassLoadEvent
		{
			var op:MassLoadEvent = super.createMassLoadEvent(file, type, evt);
			op.priority = getFilePriority(file);
			return op;
		}
	}}