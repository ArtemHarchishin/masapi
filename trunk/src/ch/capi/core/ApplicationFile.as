package ch.capi.core 
{	import ch.capi.net.ILoadableFile;
	import ch.capi.data.IMap;
	import ch.capi.data.DictionnaryMap;
	import ch.capi.errors.NameAlreadyExistsError;
	import ch.capi.errors.DependencyNotSafeError;
	
	/**
	 * Represents an application file.
	 * 
	 * @see		ch.capi.core.ApplicationFileParser	ApplicationFileParser
	 * @see		ch.capi.core.ApplicationMassLoader	ApplicationMassLoader	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public class ApplicationFile
	{
		//---------//
		//Variables//
		//---------//
		private static var __files:IMap				= new DictionnaryMap();
		private var _dependencies:Array				= new Array();
		private var _global:Boolean					= false;
		private var _name:String;
		private var _loadableFile:ILoadableFile;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
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
		 * @throws	ch.capi.errors.NameAlreadyExistsError	If the specified name already exists.
		 */
		public function ApplicationFile(name:String, loadableFile:ILoadableFile=null):void
		{
			_loadableFile = loadableFile;
			_name = name;
			
			if (__files.containsKey(name)) throw new NameAlreadyExistsError("File name '"+name+"' already exists");
			__files.put(name, this);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Retrieves the specified <code>ApplicationFile</code>. 
		 * 
		 * @param	name		The name of the file to retrieve.
		 * @return	The <code>ApplicationFile</code> or <code>null</code>.
		 */
		public static function getFile(name:String):ApplicationFile
		{
			return __files.getValue(name) as ApplicationFile;
		}
		
		/**
		 * Enumerates all the <code>ApplicationFile</code>.
		 * 
		 * @param	globalOnly		Defines if only the global files or all the files must be listed.
		 * @return	An <code>Array</code> containing the enumerated <code>ApplicationFile</code>.
		 */
		public static function enumerateFiles(globalOnly:Boolean=false):Array
		{
			var c:Array = new Array();
			var f:Array = __files.values();

			for each(var a:ApplicationFile in f)
			{
				if (!globalOnly || a.global) c.push(a);
			}
			
			return c;
		}
		
		/**
		 * Add an <code>ApplicationFile</code> as dependency for this file. It means that the specified
		 * <code>file</code> is necessary to be loaded before the current <code>ApplicationFile</code> can
		 * be executed.
		 * 
		 * @param	file		The <code>ApplicationFile</code> to add.
		 * @throws	ch.capi.errors.DependencyNotSafeError	If the dependency is not safe.
		 */
		public function addDependency(file:ApplicationFile):void
		{
			if (!isDependencySafe(file)) throw new DependencyNotSafeError("Dependency not safe for file '"+file+"'");
			
			_dependencies.push(file);
		}
		
		/**
		 * Removes a dependency from the <code>ApplicationFile</code>.
		 * 
		 * @param	file				The dependency to remove.
		 * @param	recursiveRemoval	Defines if the dependency removal must be recursive.
		 */
		public function removeDependency(file:ApplicationFile, recursiveRemoval:Boolean=false):void
		{
			var l:uint = _dependencies.length;
			for (var i:uint=0 ; i<l ; i++)
			{
				var ap:ApplicationFile = _dependencies[i];
				if (ap == file)
				{
					_dependencies.splice(i, 1);
					return;
				}
				else if (recursiveRemoval)
				{
					ap.removeDependency(file, true);
				}
			}
		}
		
		/**
		 * Retrieves the data of the <code>ILoadableFile</code> linked to the <code>ApplicationFile</code>. If
		 * the <code>loadManagerObject</code> is a <code>URLLoader</code>, then the data are returned else the
		 * <code>loadManagerObject</code> itself is returned.
		 * 
		 * @return	The data of the <code>ILoadableFile</code>.
		 * @see		#loadableFile	loadableFile
		 * @see		ch.capi.net.ILoadableFile#getData()	ILoadableFile.getData()
		 */
		public function getData():*
		{
			return loadableFile.getData();
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