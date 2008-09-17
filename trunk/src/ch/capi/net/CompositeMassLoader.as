package ch.capi.net 
{
	import flash.net.URLRequest;		
	
	import ch.capi.data.ArrayList;	
	import ch.capi.net.LoadableFileFactory;
	import ch.capi.net.IMassLoader;
	import ch.capi.net.MassLoader;
	import ch.capi.net.ILoadableFile;
	
	/**
	 * This is a utility class to avoid too much verbose code within the masapi API. Note that this
	 * class simply uses the <code>IMassLoader</code> and <code>LoadableFileFactory</code> to creates
	 * the <code>ILoadableFile</code> and for the loading management.
	 *
	 * <p>The <code>CompositeMassLoader</code> keeps by default a reference to the created <code>ILoadableFile</code>
	 * (see the <code>keepFiles</code> property).</p>
	 *
	 * @example
	 * The <code>CompositeMassLoader</code> keep a reference to the created files by default :
	 * <listing version="3.0">
	 * var cm:CompositeMassLoader = new CompositeMassLoader();
	 * cm.addFile("myAnimation.swf");
	 * cm.addFile("otherSWF.swf", LoadableFileType.BINARY);
	 * cm.addFile("myVariables.txt");
	 * 
	 * cm.start();
	 * </listing>
	 *
	 * @example
	 * The <code>CompositeMassLoader</code> doesn't keep a reference to the created files :
	 * 
	 * <listing version="3.0">
	 * var cm:CompositeMassLoader = new CompositeMassLoader(false);
	 * var file1:ILoadableFile = cm.addFile("myAnimation.swf");
	 * var file2:ILoadableFile = cm.addFile("otherSWF.swf", LoadableFileType.BINARY);
	 * var file3:ILoadableFile = cm.addFile(new URLRequest("anotherFile.txt"));
	 * 
	 * cm.start();
	 * </listing>
	 *
	 * @see			ch.capi.net.LoadableFileFactory 	LoadableFileFactory
	 * @see			ch.capi.net.IMassLoader				IMassLoader
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class CompositeMassLoader 
	{
		//---------//
		//Variables//
		//---------//
		private var _storage:ArrayList = new ArrayList();
		private var _factory:LoadableFileFactory;
		private var _massLoader:IMassLoader;
		private var _keepFiles:Boolean;

		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines if the <code>CompositeMassLoader</code> must keep references on the created
		 * <code>ILoadableFile</code> instances. If this is set to <code>false</code>, a reference must
		 * be kept on the <code>ILoadableFile</code> to prevent the Garbage Collector to delete them.
		 * 
		 * @see		#storeFile	storeFile()
		 */
		public function get keepFiles():Boolean { return _keepFiles; }
		
		/**
		 * Defines the <code>LoadableFileFactory</code> to use.
		 */
		public function get loadableFileFactory():LoadableFileFactory { return _factory; }
		public function set loadableFileFactory(value:LoadableFileFactory):void
		{ 
			if (value == null) throw new ArgumentError("value is not defined");
			_factory = value;
		}
		
		/**
		 * Defines the <code>IMassLoader</code> to use.
		 */
		public function get massLoader():IMassLoader { return _massLoader; }
		public function set massLoader(value:IMassLoader):void
		{
			if (value == null) throw new ArgumentError("value is not defined");
			_massLoader = value;
		}
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>CompositeMassLoader</code> object.
		 * 
		 * @param	keepFiles				If the <code>CompositeMassLoader</code> must keep a reference on the created <code>ILoadableFile</code> instances.
		 * @param	massLoader				The <code>IMassLoader</code> to use.
		 * @param	loadableFileFactory		The <code>LoadableFileFactory</code> to use.
		 */
		public function CompositeMassLoader(keepFiles:Boolean = true, massLoader:IMassLoader=null, loadableFileFactory:LoadableFileFactory=null)
		{
			if (massLoader == null) massLoader = new MassLoader();
			if (loadableFileFactory == null) loadableFileFactory = new LoadableFileFactory();
			
			_keepFiles = keepFiles;
			_massLoader = massLoader;
			_factory = loadableFileFactory;
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Creates a <code>ILoadableFile</code> from a url. This method doesn't register the file to the <code>IMassLoader</code> but
		 * it stores it into the <code>CompositeMassLoader</code>.
		 * 
		 * @param 	url			The url of the file.
		 * @param	fileType	The type of the file.
		 * @param	onOpen		The <code>Event.OPEN</code> listener.
		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.
		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.
		 * @param	onClose		The <code>Event.CLOSE</code> listener.
		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.
		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.
		 * @return	The created <code>ILoadableFile</code>.
		 * @see ch.capi.net.LoadableFileFactory#getRequest()	LoadableFileFactory.getRequest()
		 */
		public function createFile(url:Object, fileType:String = null,
											onOpen:Function=null, 
								   			onProgress:Function=null, 
								   			onComplete:Function=null, 
								   			onClose:Function=null,
								   			onIOError:Function=null,
								   			onSecurityError:Function=null):ILoadableFile
		{
			var request:URLRequest = LoadableFileFactory.getRequest(url);
			var file:ILoadableFile = createLoadableFile(request, fileType);
			_factory.attachListeners(file,onOpen, onProgress, onComplete, onClose, onIOError, onSecurityError);
			
			if (keepFiles) storeFile(file);
			
			return file;
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> from a url and add it to the current loading queue.
		 * 
		 * @param 	url			The url of the file.
		 * @param	fileType	The type of the file.
		 * @param	onOpen		The <code>Event.OPEN</code> listener.
		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.
		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.
		 * @param	onClose		The <code>Event.CLOSE</code> listener.
		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.
		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.
		 * @return	The created <code>ILoadableFile</code>.
		 * @see ch.capi.net.LoadableFileFactory#getRequest()	LoadableFileFactory.getRequest()
		 */
		public function addFile(url:Object, fileType:String = null,
											onOpen:Function=null, 
								   			onProgress:Function=null, 
								   			onComplete:Function=null, 
								   			onClose:Function=null,
								   			onIOError:Function=null,
								   			onSecurityError:Function=null):ILoadableFile
		{
			var request:URLRequest = LoadableFileFactory.getRequest(url);
			var file:ILoadableFile = createLoadableFile(request, fileType);
			_factory.attachListeners(file,onOpen, onProgress, onComplete, onClose, onIOError, onSecurityError);
			_massLoader.addFile(file);
			
			if (keepFiles) storeFile(file);
			
			return file;
		}
		
		/**
		 * Retrieves all the files created by the <code>CompositeMassLoader</code>. Note that the <code>CompositeMassLoader</code>
		 * register the files only if the <code>keepFiles</code> property is set to <code>true</code>.
		 * 
		 * @return	The created <code>ILoadableFile</code>.
		 */
		public function getFiles():Array
		{
			return _storage.toArray();
		}
		
		/**
		 * Retrieves the <code>ILoadableFile</code> at the specified index.
		 * 
		 * @param	index	The index.
		 * @return	The <code>ILoadableFile</code>.
		 */
		public function getFileAt(index:uint):ILoadableFile
		{
			return _storage.getElementAt(index) as ILoadableFile;
		}
		
		/**
		 * Retrieves the number of <code>ILoadableFile</code> instances that have been stored.
		 * 
		 * @return	The number of stored <code>ILoadableFile</code>.
		 */
		public function getFileCount():uint
		{
			return _storage.length;
		}

		/**
		 * Starts the loading of the massive loader.
		 * 
		 * @see	ch.capi.net.ILoadManager#start	ILoadManager.start()
		 */
		public function start():void
		{
			_massLoader.start();
		}
		
		/**
		 * Stops the loading of the massive loader.
		 * 
		 * @see	ch.capi.net.ILoadManager#stop	ILoadManager.stop()
		 */
		public function stop():void
		{
			_massLoader.stop();
		}
		
		/**
		 * Clears the loading queue of the <code>IMassLoader</code> and empty the references to the
		 * created <code>ILoadableFile</code> instances.
		 * 
		 * @see	ch.capi.net.IMassLoader#clear	IMassLoader.clear()
		 */
		public function clear():void
		{
			_massLoader.clear();
			_storage.clear();
		}
		
		//-------------------//
		//Protected functions//
		//-------------------//
		
		/**
		 * Retrieves a <code>ILoadableFile</code> from a <code>URLRequest</code> and and a specified file type
		 * issued from the <code>LoadableFileType</code> constants.
		 * 
		 * @param	request		The <code>URLRequest</code>.
		 * @param	fileType	The type of the file.
		 * @return	The <code>ILoadableFile</code> created.
		 * @throws	ArgumentError	If the <code>fileType</code> is not valid.
		 * @see ch.capi.net.LoadableFileFactory#getRequest()	LoadableFileFactory.getRequest()
		 */
		protected function createLoadableFile(request:URLRequest, fileType:String=null):ILoadableFile
		{
			return _factory.createFile(request, fileType);
		}
		
		/**
		 * Stores the specified <code>ILoadableFile</code>.
		 * 
		 * @param file	The file to store.
		 */
		protected function storeFile(file:ILoadableFile):void
		{
			_storage.addElement(file);
		}
	}
}
