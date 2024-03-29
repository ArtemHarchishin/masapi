package ch.capi.net.app 
{
	import flash.system.ApplicationDomain;	
	
	import ch.capi.data.text.IProperties;
	import ch.capi.net.ILoadableFile;
	import ch.capi.errors.DependencyNotSafeError;
	
	/**
	 * Represents an application file. An <code>ApplicationFile</code> is always registered in
	 * an <code>IApplicationContext</code> that will manage the unicity of each <code>ApplicationFile</code>.
	 * Basically, an <code>ApplicationFile</code> just holds an <code>ILoadableFile</code> and stores
	 * the dependencies of it.
	 * 
	 * @see		ch.capi.net.app.ApplicationFileParser	ApplicationFileParser
	 * @see		ch.capi.net.app.ApplicationMassLoader	ApplicationMassLoader
	 * @see		ch.capi.net.app.ApplicationContext		ApplicationContext	 * @author	Cedric Tabin - thecaptain
	 * @version	2.0	 */	public final class ApplicationFile
	{
		//---------//
		//Variables//
		//---------//
		private var _dependencies:Array				= new Array();
		private var _global:Boolean					= false;
		private var _name:String;
		private var _loadableFile:ILoadableFile;
		private var _applicationContext:IApplicationContext;
		private var _priority:int					= 0;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the <code>IApplicationContext</code> of the <code>ApplicationFile</code>.
		 */
		public function get applicationContext():IApplicationContext { return _applicationContext; }
		
		/**
		 * this method is just used to communicate the context between the ApplicationFile and ApplicationContext classes
		 * and shouldn't be used !
		 */
		internal function setContext(value:IApplicationContext):void { _applicationContext = value; }
		
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
		/**
		 * Defines the priority of the <code>ApplicationFile</code>. This value is only used if the <code>ApplicationFile</code>
		 * is directly added in the <code>ApplicationMassLoader</code>.
		 * 
		 * @see	ch.capi.net.app.ApplicationMassLoader#addApplicationFile()	ApplicationMassLoader.addApplicationFile()
		 */
		public function get priority():int { return _priority; }
		public function set priority(value:int):void { _priority = value; }
		
		/**
		 * Defines the <code>Properties</code> of the linked <code>ILoadableFile</code>.
		 * 
		 * @see		ch.capi.net.ILoadableFile#properties	ILoadableFile.properties
		 */
		public function get properties():IProperties { return _loadableFile.properties; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ApplicationFile</code> object.
		 * 
		 * @param	name				The name. It must be unique !
		 * @param	context				The <code>IApplicationContext</code>. If not specified, then the global context will be used.
		 * @param	loadableFile		The linked <code>ILoadableFile</code>.
		 * @throws	ch.capi.errors.NameAlreadyExistsError	If the specified name already exists in the specified <code>IApplicationContext</code>.
		 */
		public function ApplicationFile(name:String, context:IApplicationContext, loadableFile:ILoadableFile=null):void
		{
			_loadableFile = loadableFile;
			_name = name;
			
			context.addFile(this);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		//TODO put the method in ApplicationContext
		/**
		 * Retrieves the <code>ApplicationFile</code> that holds the specified <code>ILoadableFile</code>.
		 * 
		 * @param	file		The <code>ILoadableFile</code>.
		 * @param	context		The <code>IApplicationContext</code>.
		 * @return	The <code>ApplicationFile</code> that holds the specified <code>ILoadableFile</code>.
		 * @throws	Error		If there is no <code>ApplicationFile</code> with the specified <code>ILoadableFile</code> in the
		 * 						specified <code>IApplicationContext</code>.
		 */
		/*public static function getByLoadableFile(file:ILoadableFile, context:IApplicationContext):ApplicationFile
		{
			var files:Array = context.enumerateAll();
			for (var i:int=0 ; i<files.length ; i++)
			{
				var apf:ApplicationFile = files[i];
				if (apf.loadableFile == file) return apf;
			}
			
			throw new Error("There is no ApplicationFile with the specified ILoadableFile in the specified context ("+file+")");
		}*/

		/**
		 * Add an <code>ApplicationFile</code> as dependency of this file. It means that the specified
		 * <code>file</code> is necessary to be loaded before the current <code>ApplicationFile</code> can
		 * be executed.
		 * <p>The <code>ApplicationFile</code> added as dependency must be in the same <code>IApplicationContext</code>.</p>
		 * 
		 * @param	file		The <code>ApplicationFile</code> to add.
		 * @throws	ArgumentError	If the <code>IApplicationContext</code> is not the same.
		 * @throws	ch.capi.errors.DependencyNotSafeError	If the dependency is not safe.
		 */
		public function addDependency(file:ApplicationFile):void
		{
			if (file.applicationContext != applicationContext) throw new ArgumentError("The IApplicationContext is not the same");
			if (!isDependencyRecursive(file)) throw new DependencyNotSafeError("Dependency not safe for file '"+file+"' (recursive dependency)");
			
			_dependencies.push(file);
		}
		
		/**
		 * Removes a dependency from the <code>ApplicationFile</code>.
		 * 
		 * @param	file				The dependency to remove.
		 * @param	recursiveSearch		Defines if the search of the dependency must recursive through the dependency tree.
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
		 * Retrieves if the <code>ApplicationFile</code> is a dependency of the specified
		 * <code>ApplicationFile</code>.
		 * 
		 * @param	file	The parent <code>ApplicationFile</code>.
		 * @param	recursiveSearch	Defines if the dependency must be searched recursively.
		 * @param	<code>true</code> if the current file is a dependency of the specified file.
		 */
		public function isDependencyOf(file:ApplicationFile, recursiveSearch:Boolean=true):Boolean
		{
			var dependencies:Array = file.dependencies;
			for each(var dependency:ApplicationFile in dependencies)
			{
				if (dependency == this) return true;
				if (recursiveSearch)
				{
					var result:Boolean = isDependencyOf(dependency, true);
					if (result == true) return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Get all the <code>ApplicationFile</code> that have this file as direct dependency.
		 * 
		 * @return	The parents.
		 */
		public function getParents():Array
		{
			var parents:Array = [];
			var files:Array = _applicationContext.enumerateAll();
			
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
		
		/**
		 * Retrieves the value of the specified key from the <code>properties</code> of the <code>ILoadableFile</code>. If 
		 * the <code>ILoadableFile</code> is not defined, <code>null</code> is returned.
		 * 
		 * @param	key		The key.
		 * @return	The value or <code>null</code>.
		 * @see		#getProperties()	getProperties()
		 */
		public function getProperty(key:*):*
		{
			if (loadableFile == null) return null;
			return loadableFile.properties.getValue(key);
		}

		/**
		 * Represents this <code>ApplicationFile</code> in a <code>String</code>. This gives just useful information
		 * for debugging purpose.
		 * 
		 * @return	A <code>String</code> representation of this <code>ApplicationFile</code>.
		 */
		public function toString():String
		{
			var str:String = "ApplicationFile["+_name+"]";
			if (loadableFile != null) str += " "+(loadableFile as Object).toString();
			return str;
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
		protected function isDependencyRecursive(file:ApplicationFile):Boolean
		{
			for each(var ap:ApplicationFile in _dependencies)
			{
				if (ap == file) return false;
				if (!ap.isDependencyRecursive(file)) return false;
			}
			
			return true;
		}
	}}