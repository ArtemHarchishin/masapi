package ch.capi.net.app{	import flash.errors.IllegalOperationError;	
	import ch.capi.errors.NameAlreadyExistsError;	
	import ch.capi.data.IMap;	import ch.capi.data.LinkedMap;		
	/**	 * Represents a context for the <code>ApplicationFile</code>.	 * 	 * @see			ch.capi.net.app.ApplicationFile	ApplicationFile	 * @author		Cedric Tabin - thecaptain	 * @version		1.1	 */	public final class ApplicationContext	{		//---------//		//Constants//		//---------//				//---------//		//Variables//		//---------//		private static var __allContexts:Array				  		= new Array();		private static var __globalContext:ApplicationContext 		= new ApplicationContext();		private var _files:IMap										= new LinkedMap();		//-----------------//		//Getters & Setters//		//-----------------//				//-----------//		//Constructor//		//-----------//				/**		 * Creates a new <code>ApplicationContext</code> object.		 */		public function ApplicationContext():void { __allContexts.push(this); }				//--------------//		//Public methods//		//--------------//				/**		 * Enumerates all <code>ApplicationContext</code> instances.		 * 		 * @return	An <code>Array</code> containing all <code>ApplicationContext</code>.		 */		public static function enumerateContexts():Array		{			return __allContexts.concat();		}		/**		 * Retrieves the global <code>ApplicationContext</code>.		 * 		 * @return	The global <code>ApplicationContext</code>.		 */		public static function getGlobalContext():ApplicationContext		{			return __globalContext;		}				/**		 * Get the <code>ApplicationFile</code> linked to the specified name.		 * 		 * @return	The <code>ApplicationFile</code> or <code>null</code>.		 */		public function getFile(name:String):ApplicationFile		{			return _files.getValue(name) as ApplicationFile;		}
		/**		 * Add the specified <code>ApplicationFile</code> to the current <code>ApplicationContext</code>. If		 * the context of the <code>ApplicationFile</code> is already specified, this method will throw an error. 		 * <p>This method will also check that all dependencies of the specified <code>ApplicationFile</code> are		 * already into the current <code>ApplicationContext</code>. If they are in no <code>ApplicationContext</code>		 * they will be added into the current one, otherwise an error will be thrown.</p>		 * 		 * @param	file	The <code>ApplicationFile</code>.		 * @throws	ArgumentError	If the <code>ApplicationContext</code> of the file is not <code>null</code>.		 * @throws	ArguemntError	If one of the dependencies is in another <code>ApplicationContext</code>.		 * @throws	NameAlreadyExistsError	If the name of the <code>ApplicationFile</code> is already taken.		 */		public function addFile(file:ApplicationFile):void		{			if (file.applicationContext != null) throw new ArgumentError("The ApplicationContext of the file '"+file.name+"' " +																			"is already defined");			if (_files.containsKey(file.name)) throw new NameAlreadyExistsError("File name '"+file.name+"' already exists");						/*			 * Try to add the dependencies of the file. If the dependency is already into			 * the current context, then the 'add' will not be recursive. 			 */			var dependencies:Array = file.dependencies;			for each(var dependency:ApplicationFile in dependencies)			{				if (dependency.applicationContext == null) addFile(dependency);				else if (dependency.applicationContext != this) throw new ArgumentError("A dependendy of the file '"+file.name+"'" +																			 " is already in another ApplicationContext");			}						//update the file data			_files.put(file.name, file);			file.setContext(this);		}				/**		 * Remove the specified <code>ApplicationFile</code> from the <code>ApplicationContext</code>. All the		 * <code>ApplicationFile</code> having the specified file as dependency, will have it removed.		 * <p>If the recursiveRemoval argument is set to <code>true</code>, then all the dependencies of the specified		 * file will also be removed from the <code>ApplicationContext</code>. In the other case, all the dependencies		 * of the specified <code>ApplicationFile</code> are cleared.</p>		 * 		 * @param	file				The <code>ApplicationFile</code> to remove.		 * @param	recursiveRemoval	If the removal must be applied on all the dependencies of the file.		 * @throws	flash.errors.IllegalOperationError	If the <code>file</code> is not into the <code>ApplicationContext</code>.			 */		public function removeFile(file:ApplicationFile, recursiveRemoval:Boolean=false):void		{			if (file.applicationContext != this) throw new IllegalOperationError("The file "+file+" is not into the specified ApplicationContext");						//remove the file			file.setContext(null);			_files.remove(file.name);						//remove the dependency from all the other files.				var files:Array = _files.values();			for each(var appFile:ApplicationFile in files)			{				appFile.removeDependency(file);			}						//if it is recursive, then apply on all the file dependencies			//otherwise, just remove the dependencies of the removed file			var dependencies:Array = file.dependencies;			for each(var dependency:ApplicationFile in dependencies)			{				if (recursiveRemoval) removeFile(dependency, true);				else file.removeDependency(dependency);			}		}		/**		 * Enumerates all the <code>ApplicationFile</code> contained into the <code>ApplicationContext</code>.		 * 		 * @param	globalOnly		Defines if only the global files or all the files must be listed.		 * @return	An <code>Array</code> containing the enumerated <code>ApplicationFile</code>.		 */		public function enumerateAll(globalOnly:Boolean=false):Array		{			var c:Array = new Array();			var f:Array = _files.values();			for each(var a:ApplicationFile in f)			{				if (!globalOnly || a.global) c.push(a);			}						return c;		}				/**		 * Enumerates all the <code>ApplicationFile</code> that are on the root of the tree. That means that no		 * other <code>ApplicationFile</code> have it as dependency.		 * 		 * @return	An <code>Array</code> containing all the <code>ApplicationFile</code> that are not in any dependency.		 * @see		#enumerateLeafs() enumerateLeafs()			 */		public function enumerateRoots():Array		{			var roots:Array = new Array();			var files:Array = _files.values();						for each(var a:ApplicationFile in files)			{				if (a.getParents().length == 0) roots.push(a);			}						return roots;		}				/**		 * Enumerates all the <code>ApplicationFile</code> that doesn't have any dependency.		 * 		 * @return	An <code>Array</code> containing all the <code>ApplicationFile</code> that doesn't have any dependency.		 * @see		#enumerateRoots()	enumerateRoots()		 */		public function enumerateLeafs():Array		{			var leafs:Array = new Array();			var files:Array = _files.values();						for each(var a:ApplicationFile in files)			{				if (a.dependencies.length == 0) leafs.push(a);			}						return leafs;		}				/**		 * Clear all the <code>ApplicationFile</code> of the <code>ApplicationContext</code>. The context property of the		 * <code>ApplicationFile</code> instances are reset to <code>null</code> to let the Garbate Collector take care of		 * the <code>ApplicationContext</code> instance.		 */		public function clear():void		{			var files:Array = _files.keys();			for each (var file:ApplicationFile in files)			{				file.setContext(null);			}						_files.clear();		}				//-----------------//		//Protected methods//		//-----------------//				//---------------//		//Private methods//		//---------------//	}}