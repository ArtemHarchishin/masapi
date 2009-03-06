package ch.capi.net.app 
{	import flash.system.ApplicationDomain;	
	
	import ch.capi.net.ILoadableFile;
	import ch.capi.errors.DependencyNotSafeError;
	
	/**
	 * Represents an application file.
	 * 
	 * @example
	 * <listing version="3.0">
	 * var xmlDependencies:XMLDocument = ... //the xml of the dependencies
	 * var parser:ApplicationFileParser = new ApplicationFileParser();
	 * parser.parse(xmlDependencies.firstChild);
	 * 
	 * //now the files are available into the default ApplicationContext
	 * var file:ApplicationFile = ApplicationFile.getFile("myFile");
	 * </listing>
	 * 
	 * @see		ch.capi.net.app.ApplicationFileParser	ApplicationFileParser
	 * @see		ch.capi.net.app.ApplicationMassLoader	ApplicationMassLoader
	 * @see		ch.capi.net.app.ApplicationContext		ApplicationContext	 * @author	Cedric Tabin - thecaptain
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
		private var _priority:int					= 0;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the <code>ApplicationContext</code> of the <code>ApplicationFile</code>.
		 */
		public function get applicationContext():ApplicationContext { return _applicationContext; }
		
		/**
		 * this method is just used to communicate the context between the ApplicationFile and ApplicationContext classes
		 * and shouldn't be used !
		 */
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
		/**
		 * Defines the priority of the <code>ApplicationFile</code>. This value is only used if the <code>ApplicationFile</code>
		 * is directly added into the <code>ApplicationMassLoader</code>.
		 * 
		 * @see	ch.capi.net.app.ApplicationMassLoader#addApplicationFile()	ApplicationMassLoader.addApplicationFile()
		 */
		public function get priority():int { return _priority; }
		public function set priority(value:int):void { _priority = value; }
		
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
			
			if (context == null) context = ApplicationContext.globalContext;
			context.addFile(this);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * THIS METHOD IS DEPRECATED. USE <code>ApplicationContext.getFile()</code> METHOD INSTEAD !
		 * Retrieves the specified <code>ApplicationFile</code>. This method is just an encapsulation to retrieve
		 * the file throught the <code>ApplicationContext</code>.
		 * 
		 * @param	name		The name of the file to retrieve.
		 * @param	context		The <code>ApplicationContext</code>. If not specified, the global context will be used.
		 * @return	The <code>ApplicationFile</code> or <code>null</code>.
		 * @see		ch.capi.net.app.ApplicationContext#getFile()	ApplicationContext.getFile()
		 * @deprecated
		 */
		public static function get(name:String, context:ApplicationContext=null):ApplicationFile
		{
			if (context == null) context = ApplicationContext.globalContext;
			return context.getFile(name);
		}
		
		/**
		 * Retrieves the <code>ApplicationFile</code> that holds the specified <code>ILoadableFile</code>.
		 * 
		 * @param	file		The <code>ILoadableFile</code>.
		 * @param	context		The <code>ApplicationContext</code>. If not specified, the global context will be used.
		 * @return	The <code>ApplicationFile</code> or <code>null</code> if there is no <code>ApplicationFile</code> that holds
		 * 			the specified <code>ILoadableFile</code>.
		 */
		public static function getByLoadableFile(file:ILoadableFile, context:ApplicationContext=null):ApplicationFile
		{
			if (context == null) context = ApplicationContext.globalContext;
			
			var files:Array = context.enumerateAll();
			for (var i:int=0 ; i<files.length ; i++)
			{
				var apf:ApplicationFile = files[i];
				if (apf.loadableFile == file) return apf;
			}
			
			return null;
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
		 */
		public function getProperty(key:*):*
		{
			if (loadableFile == null) return null;
			return loadableFile.properties.getValue(key);
		}
		
		/**
		 * Represents this <code>ApplicationFile</code> into a <code>String</code>. This gives just useful information
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