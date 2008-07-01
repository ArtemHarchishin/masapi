package ch.capi.core 
{	import flash.system.ApplicationDomain;	
	
	import ch.capi.net.ILoadableFile;
	import ch.capi.errors.DependencyNotSafeError;
	
	/**
	 * Represents an application file.
	 * 
	 * @see		ch.capi.core.ApplicationFileParser	ApplicationFileParser
	 * @see		ch.capi.core.ApplicationMassLoader	ApplicationMassLoader	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public final class ApplicationFile
	{
		//---------//
		//Variables//
		//---------//
		private var _dependencies:Array				= new Array();
		private var _global:Boolean					= false;
		private var _name:String;
		private var _loadableFile:ILoadableFile;
		private var _applicationContext:ApplicationContext;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the <code>ApplicationContext</code> of the <code>ApplicationFile</code>.
		 */
		public function get applicationContext():ApplicationContext { return _applicationContext; }
		
		//this method is just used to communicate the context between the ApplicationFile and ApplicationContext classes
		//and shouldn't be used !
		internal function setContext(value:ApplicationContext):void { _applicationContext = value; }
		
		/**
		 * Defines the <code>ILoadableFile</code>.
		 */
		public function get loadableFile():ILoadableFile { return _loadableFile; }
		public function set loadableFile(value:ILoadableFile):void { _loadableFile = value; }
		
		/**
		 * Defines the dependencies. This is an <code>Array</code> of <code>ApplicationFile</code> that
		 * is duplicated from the original <code>Array</code>.
		 */
		public function get dependencies():Array { return _dependencies.concat(); }
		
		/**
		 * Defines the name. The name is unique trough all the <code>ApplicationFile</code> objects.
		 */
		public function get name():String { return _name; }
		
		/**
		 * Defines if the <code>ApplicationFile</code> is global or not.
		 */
		public function get global():Boolean { return _global; }
		public function set global(value:Boolean):void { _global = value; }		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ApplicationFile</code> object.
		 * 
		 * @param	name				The name. It must be unique !
		 * @param	loadableFile		The linked <code>ILoadableFile</code>.
		 * @param	context				The <code>ApplicationContext</code>. If not specified, then the global context will be used.
		 * @throws	ch.capi.errors.NameAlreadyExistsError	If the specified name already exists into the specified <code>ApplicationContext</code>.
		 */
		public function ApplicationFile(name:String, loadableFile:ILoadableFile=null, context:ApplicationContext=null):void
		{
			_loadableFile = loadableFile;
			_name = name;
			
			if (context == null) context = ApplicationContext.getGlobalContext();
			context.addFile(this);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Retrieves the specified <code>ApplicationFile</code>. This method is just an encapsulation to retrieve
		 * the file throught the <code>ApplicationContext</code>.
		 * 
		 * @param	name		The name of the file to retrieve.
		 * @param	context		The <code>ApplicationContext</code>. If not specified, the global context will be used.
		 * @return	The <code>ApplicationFile</code> or <code>null</code>.
		 */
		public static function getFile(name:String, context:ApplicationContext=null):ApplicationFile
		{
			if (context == null) context = ApplicationContext.getGlobalContext();
			return context.getFile(name);
		}
		
		/**
		 * Add an <code>ApplicationFile</code> as dependency for this file. It means that the specified
		 * <code>file</code> is necessary to be loaded before the current <code>ApplicationFile</code> can
		 * be executed.
		 * <p>The <code>ApplicationFile</code> added as dependency must be into the same <code>ApplicationContext</code>.</p>
		 * 
		 * @param	file		The <code>ApplicationFile</code> to add.
		 * @throws	ArgumentError	If the <code>ApplicationContext</code> is not the same.
		 * @throws	ch.capi.errors.DependencyNotSafeError	If the dependency is not safe.
		 */
		public function addDependency(file:ApplicationFile):void
		{
			if (file.applicationContext != applicationContext) throw new ArgumentError("The ApplicationContext is not the same");
			if (!isDependencySafe(file)) throw new DependencyNotSafeError("Dependency not safe for file '"+file+"'");
			
			_dependencies.push(file);
		}
		
		/**
		 * Removes a dependency from the <code>ApplicationFile</code>.
		 * 
		 * @param	file				The dependency to remove.
		 * @param	recursiveSearch		Defines if the search of the dependency must recursive trought the dependency tree.
		 * 								The removal will be stopped after the first instance of the dependency has been found.
		 */
		public function removeDependency(file:ApplicationFile, recursiveSearch:Boolean=false):void
		{
			var dependencies:uint = _dependencies.length;
			for (var i:uint=0 ; i<dependencies ; i++)
			{
				var appFile:ApplicationFile = _dependencies[i];
				if (appFile == file)
				{
					_dependencies.splice(i, 1);
					return;
				}
				else if (recursiveSearch)
				{
					appFile.removeDependency(file, true);
				}
			}
		}
		
		/**
		 * Removes all the dependencies of the <code>ApplicationFile</code>.
		 */
		public function clearDependencies():void
		{
			_dependencies = [];
		}
		
		/**
		 * Retrieves if the <code>ApplicationFile</code> is a direct dependency of the specified
		 * <code>ApplicationFile</code>.
		 * 
		 * @param	file	The parent <code>ApplicationFile</code>.
		 * @param	<code>true</code> if the current file is a dependency of the specified file.
		 */
		public function isDependencyOf(file:ApplicationFile):Boolean
		{
			var dependencies:Array = file.dependencies;
			for each(var dependency:ApplicationFile in dependencies)
			{
				if (dependency == this) return true;
			}
			
			return false;
		}
		
		/**
		 * Get all the <code>ApplicationFile</code> that have this file as directed dependency.
		 * 
		 * @return	The parents.
		 */
		public function getParents():Array
		{
			var parents:Array = [];
			var files:Array = _applicationContext.enumerateFiles();
			
			for each(var file:ApplicationFile in files)
			{
				if (file != this && this.isDependencyOf(file))
				{
					parents.push(file);
				}
			}
			
			return parents;
		}
		/**
		 * Retrieves the data of the <code>ILoadableFile</code> linked to the <code>ApplicationFile</code>. If
		 * the <code>loadManagerObject</code> is a <code>URLLoader</code>, then the data are returned else the
		 * <code>loadManagerObject</code> itself is returned.
		 * 
		 * @param	asClass		The class that should be returned by the method (cf ILoadableFile implementation).
		 * @param	appDomain	The <code>ApplicationDomain</code> of the class.	
		 * @return	The data of the <code>ILoadableFile</code>.
		 * @see		#loadableFile	loadableFile
		 * @see		ch.capi.net.ILoadableFile#getData()	ILoadableFile.getData()
		 */
		public function getData(asClass:String=null, appDomain:ApplicationDomain=null):*
		{
			if (loadableFile == null) return null;
			return loadableFile.getData(asClass, appDomain);
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Check if the dependency is safe for a <code>ApplicationFile</code>.
		 * 
		 * @param	file	The file to add as a dependency.
		 * @return	<code>true</code> is the dependency is safe.
		 */
		protected function isDependencySafe(file:ApplicationFile):Boolean
		{
			for each(var ap:ApplicationFile in _dependencies)
			{
				if (ap == file) return false;
				if (!ap.isDependencySafe(file)) return false;
			}
			
			return true;
		}
	}}