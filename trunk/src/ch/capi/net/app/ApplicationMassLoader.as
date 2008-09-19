package ch.capi.net.app 
{
	import ch.capi.net.PriorityMassLoader;
	import ch.capi.net.IMassLoader;
	import ch.capi.net.ILoadableFile;
	import ch.capi.net.app.ApplicationFile;
	
	/**
	 * Manages the massive loading of <code>ApplicationFile</code>.
	 * 
	 * @see		ch.capi.net.app.ApplicationFile			ApplicationFile
	 * @see		ch.capi.net.app.ApplicationFileParser	ApplicationFileParser	 * @author 	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public class ApplicationMassLoader extends PriorityMassLoader implements IMassLoader
	{
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ApplicationMassLoader</code> object.
		 * 
		 * @param	loadByPriority		Defines if the <code>ApplicationMassLoader</code> must load the files by priority.
		 * @param	prallelFiles		Defines how many file to load at the same time. This value will affect the loading only if the
		 * 								<code>loadByPriority</code> property is <code>false</code>.
		 */
		public function ApplicationMassLoader(loadByPriority:Boolean=true, parallelFiles:uint=0):void 
		{
			super(loadByPriority, parallelFiles);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Add the global <code>ApplicationFile</code> into the loading queue.
		 * 
		 * @param	context		The <code>ApplicationContext</code>. If not specified, the global context will be used.
		 */
		public function addGlobalFiles(context:ApplicationContext=null):void
		{
			if (context == null) context = ApplicationContext.getGlobalContext();
			var f:Array = context.enumerateAll(true);
			for each(var a:ApplicationFile in f)
			{
				addApplicationFile(a);
			}
		}
		
		/**
		 * Add the specified <code>ApplicationFile</code> and its dependencies.
		 * 
		 * @param	file		The <code>ApplicationFile</code> to add.
		 * @param	priority	The priority of the <code>ApplicationFile</code>. All the dependencies will have a
		 * 						higher priority (+1). 
		 */
		public function addApplicationFile(file:ApplicationFile):void
		{
			addApplicationFileRecursively(file, file.priority);
		}
		
		/**
		 * Add all the <code>ApplicationFile</code> objects that are into a specified <code>ApplicationContext</code> into
		 * the loading queue. If the context is not specified, the global <code>ApplicationContext</code> will be used.
		 * 
		 * @param context			The <code>ApplicationContext</code>.
		 * @return	An <code>Array</code> containing all the <code>ApplicationFile</code> added to the loading queue.
		 * @see		ch.capi.net.app.ApplicationContext#enumerateRoots()	ApplicationContext.enumerateRoots()
		 */
		public function addAll(context:ApplicationContext=null):Array
		{
			if (context == null) context = ApplicationContext.getGlobalContext();
			
			var files:Array = context.enumerateRoots();
			for each(var appFile:ApplicationFile in files)
			{
				addApplicationFile(appFile);
			}
			
			return files;
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Add the specified <code>ILoadableFile</code> to the queue within the priority. If the <code>ILoadableFile</code> is
		 * already into the loading queue, then it checks if the priority must be udpated or not.
		 * 
		 * @param	file		The <code>ILoadableFile</code>.
		 * @param	priority	The priority.
		 */
		protected function addLoadableFile(file:ILoadableFile, priority:int):void
		{
			if (hasFile(file)) //the file is contained into the queue, see if the priority must be updated
			{
				var pr:int = getFilePriority(file);
				
				//the file doesn't need to be updated
				if (priority <= pr) return;
				
				//update the file => remove it, it will be readded
				//with the right priority
				removeFile(file);
			}
			
			addPrioritizedFile(file, priority);
		}
		
		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 */
		private function addApplicationFileRecursively(file:ApplicationFile, level:int):void
		{
			var dep:Array = file.dependencies;
			for each(var af:ApplicationFile in dep)
			{
				addApplicationFileRecursively(af, level+1);
			}
			
			var lf:ILoadableFile = file.loadableFile;
			addLoadableFile(lf, level);
		}	}}