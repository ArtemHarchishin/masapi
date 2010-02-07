package ch.capi.net.app{	/**	 * Represents a context for the <code>ApplicationFile</code>.	 * 	 * @author		Cedric Tabin - thecaptain	 * @version		1.0	 */	public interface IApplicationContext	{		/**		 * Defines the name of the <code>ApplicationContext</code>.		 */		function get name():String;		/**		 * Get the <code>ApplicationFile</code> linked to the specified name.		 * 		 * @param	name	The name of the <code>ApplicationFile</code>.		 * @return	The <code>ApplicationFile</code> or <code>null</code> if the file doesn't exist.		 * @throws	Error	If there is no <code>ApplicationFile</code> matching the specified name.		 */		function getFile(name:String):ApplicationFile;			/**		 * Retrieves the first <code>ApplicationFile</code> that matches the specified properties.		 * 		 * @param	props		An <code>Object</code> containing the properties to match.		 * @param	strict		Defines if the check must be strict or not.		 * @return	The first <code>ApplicationFile</code> instance that matches the properties		 * 			or <code>null</code>.		 * 					 * @see		ch.capi.net.ILoadableFile#properties	ILoadableFile.properties		 * @see		ch.capi.data.IMap#matches()				IMap.matches()		 */		function getFileByProps(props:Object, strict:Boolean=false):ApplicationFile;				/**		 * Retrieves all the files that matche the specified properties.		 * 		 * @param	props		An <code>Object</code> containing the properties to match.		 * @param	strict		Defines if the check must be strict or not.		 * @return	An <code>Array</code> of <code>ILoadableFile</code> that matche the 		 * 			specified properties.		 * 					 * @see		ch.capi.net.ILoadableFile#properties	ILoadableFile.properties		 * @see		ch.capi.data.IMap#matches()				IMap.matches()		 */		function getFilesByProps(props:Object, strict:Boolean=false):Array;		/**		 * Add the specified <code>ApplicationFile</code> to the current <code>ApplicationContext</code>. If		 * the context of the <code>ApplicationFile</code> is already specified, this method will throw an error. 		 * <p>This method will also check that all dependencies of the specified <code>ApplicationFile</code> are		 * already in the current <code>ApplicationContext</code>. If they are in no <code>ApplicationContext</code>		 * they will be added in the current one, otherwise an error will be thrown.</p>		 * 		 * @param	file	The <code>ApplicationFile</code>.		 * @throws	ArgumentError	If the <code>ApplicationContext</code> of the file is not <code>null</code>.		 * @throws	ArguemntError	If one of the dependencies is in another <code>ApplicationContext</code>.		 * @throws	NameAlreadyExistsError	If the name of the <code>ApplicationFile</code> is already taken.		 */		function addFile(file:ApplicationFile):void;				/**		 * Remove the specified <code>ApplicationFile</code> from the <code>ApplicationContext</code>. All the		 * <code>ApplicationFile</code> having the specified file as dependency, will have it removed.		 * <p>If the recursiveRemoval argument is set to <code>true</code>, then all the dependencies of the specified		 * file will also be removed from the <code>ApplicationContext</code>. In the other case, all the dependencies		 * of the specified <code>ApplicationFile</code> are cleared.</p>		 * 		 * @param	file				The <code>ApplicationFile</code> to remove.		 * @param	recursiveRemoval	If the removal must be applied on all the dependencies of the file.		 * @throws	flash.errors.IllegalOperationError	If the <code>file</code> is not in the <code>ApplicationContext</code>.			 */		function removeFile(file:ApplicationFile, recursiveRemoval:Boolean=false):void;		/**		 * Enumerates all the global <code>ApplicationFile</code> contained in the <code>ApplicationContext</code>.		 * 		 * @return	An <code>Array</code> containing the enumerated <code>ApplicationFile</code>.		 */		function enumerateGlobals():Array;		/**		 * Enumerates all the <code>ApplicationFile</code> contained in the <code>ApplicationContext</code>.		 * 		 * @param	excludeGlobalFiles		Defines if the global files must be excluded.		 * @return	An <code>Array</code> containing the enumerated <code>ApplicationFile</code>.		 */		function enumerateAll(excludeGlobalFiles:Boolean=false):Array;				/**		 * Enumerates all the <code>ApplicationFile</code> that are on the root of the tree. That means that no		 * other <code>ApplicationFile</code> have it as dependency.		 * 		 * @return	An <code>Array</code> containing all the <code>ApplicationFile</code> that are not in any dependency.		 * @see		#enumerateLeaves() enumerateLeaves()			 */		function enumerateRoots():Array;				/**		 * Enumerates all the <code>ApplicationFile</code> that doesn't have any dependency.		 * 		 * @return	An <code>Array</code> containing all the <code>ApplicationFile</code> that doesn't have any dependency.		 * @see		#enumerateRoots()	enumerateRoots()		 */		function enumerateLeaves():Array;				/**		 * Clear all the <code>ApplicationFile</code> of the <code>ApplicationContext</code>. The context property of the		 * <code>ApplicationFile</code> instances are reset to <code>null</code> to let the Garbate Collector take care of		 * the <code>ApplicationContext</code> instance.		 */		function clear():void;	}}