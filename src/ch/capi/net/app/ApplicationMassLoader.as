package ch.capi.net.app 
{
	import flash.errors.IllegalOperationError;	
	
	import ch.capi.net.PriorityMassLoader;
	import ch.capi.net.IMassLoader;
	import ch.capi.net.ILoadableFile;
	import ch.capi.net.app.ApplicationFile;
	
	/**
	 * Manages the massive loading of <code>ApplicationFile</code>.
	 * 
	 * @see		ch.capi.net.app.ApplicationFile			ApplicationFile
	 * @see		ch.capi.net.app.ApplicationFileParser	ApplicationFileParser
	 * @see		ch.capi.net.app.ApplicationConfigLoader	ApplicationConfigLoader	 * @author 	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public class ApplicationMassLoader extends PriorityMassLoader implements IMassLoader
	{
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ApplicationMassLoader</code> object.
		 * 
		 * @param	prallelFiles		Defines how many file to load at the same time. This value will affect the loading only if the
		 * 								<code>loadByPriority</code> property is <code>false</code>.
		 * @param	loadByPriority		Defines if the <code>ApplicationMassLoader</code> must load the files by priority.
		 */
		public function ApplicationMassLoader(parallelFiles:uint=0, loadByPriority:Boolean=false):void 
		{
			super(parallelFiles, loadByPriority);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Add the global <code>ApplicationFile</code> in the loading queue.
		 * 
		 * @param	context		The <code>IApplicationContext</code>.
		 */
		public function addGlobalFiles(context:IApplicationContext):void
		{
			var f:Array = context.enumerateGlobals();
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
		 * 						higher priority (+1). The priority of the <code>ApplicationFile</code> is stored in the
		 * 						<code>ApplicationMassLoader</code>, so it won't be affected, even if you change it.
		 */
		public function addApplicationFile(file:ApplicationFile):void
		{
			addApplicationFileRecursively(file, file.priority);
		}
		
		/**
		 * Add all the <code>ApplicationFile</code> objects that are in a specified <code>ApplicationContext</code> in
		 * the loading queue.
		 * 
		 * @param context			The <code>IApplicationContext</code>.
		 * @return	An <code>Array</code> containing all the <code>ApplicationFile</code> added to the loading queue.
		 * @see		ch.capi.net.app.ApplicationContext#enumerateRoots()	ApplicationContext.enumerateRoots()
		 */
		public function addAll(context:IApplicationContext):Array
		{
			var files:Array = context.enumerateRoots();
			for each(var appFile:ApplicationFile in files)
			{
				addApplicationFile(appFile);
			}
			
			return files;
		}
		
		/**
		 * Starts the loading of the specified file. If the file isn't an <code>ApplicationFile</code> then the toString() method
		 * will be used to retrieve it from the specified <code>ApplicationContext</code>.
		 * 
		 * @param	file			The <code>ApplicationFile</code> object or the name of the <code>ApplicationFile</code>. If this param
		 * 							is a <code>String</code>, then the <code>IApplicationContext</code> must be specified.
		 * @param	context			The <code>IApplicationContext</code> to retrieve the <code>ApplicationFile</code> and global files.
		 * @param	withGlobalFiles	Tells the <code>ApplicationMassLoader</code> to automatically add the <code>ApplicationFile</code>
		 * 							that are noted as global (<code>IApplicationContext</code> must be specified).
		 * @return	The <code>ApplicationFile</code> being loaded.
		 * @throws	IllegalOperationError	If the <code>ApplicationmassLoader</code> is currently loading.
		 */
		public function load(file:Object, context:IApplicationContext=null, withGlobalFiles:Boolean=false):ApplicationFile
		{
			if (stateLoading) throw new IllegalOperationError("The ApplicationMassLoader is already loading when trying to add file "+file);
			
			//retrieves the specified file
			var appFile:ApplicationFile = (file is ApplicationFile) ? (file as ApplicationFile) : context.getFile(file.toString());
			
			//add the global files
			if (withGlobalFiles) addGlobalFiles(context);
			
			//load the specified file
			addApplicationFile(appFile);
			start();
			
			return appFile;	 
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Add the specified <code>ILoadableFile</code> to the queue within the priority. If the <code>ILoadableFile</code> is
		 * already in the loading queue, then it checks if the priority must be udpated or not.
		 * 
		 * @param	file		The <code>ILoadableFile</code>.
		 * @param	priority	The priority.
		 */
		protected function addLoadableFile(file:ILoadableFile, priority:int):void
		{
			if (hasFile(file)) //the file is contained in the queue, see if the priority must be updated
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
			
			//add the ILoadableFile in the queue only if it exists
			var lf:ILoadableFile = file.loadableFile;
			if (lf != null) addLoadableFile(lf, level);
		}	}}