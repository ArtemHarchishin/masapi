package ch.capi.net 
{
	import flash.net.URLRequest;		
	
	import ch.capi.net.LoadableFileFactory;
	import ch.capi.net.IMassLoader;
	import ch.capi.net.MassLoader;
	import ch.capi.net.ILoadableFile;
	
	/**
	 * This is a utility class to avoid too much verbose code within the masapi API. Note that this
	 * class simply uses the <code>IMassLoader</code> and <code>LoadableFileFactory</code> to creates
	 * the <code>ILoadableFile</code> and for the loading management.
	 *
	 * @example
	 * <listing version="3.0">
	 * var cm:CompositeMassLoader = new CompositeMassLoader();
	 * cm.addFile("myAnimation.swf");
	 * cm.addFile("otherSWF.swf", LoadableFileType.BINARY);
	 * cm.addFile("myVariables.txt");
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
		private var _factory:LoadableFileFactory;
		private var _massLoader:IMassLoader;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
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
		 * @param	massLoader				The <code>IMassLoader</code> to use.
		 * @param	loadableFileFactory		The <code>LoadableFileFactory</code> to use.
		 */
		public function CompositeMassLoader(massLoader:IMassLoader=null, loadableFileFactory:LoadableFileFactory=null)
		{
			if (massLoader == null) massLoader = new MassLoader();
			if (loadableFileFactory == null) loadableFileFactory = new LoadableFileFactory();
			
			_massLoader = massLoader;
			_factory = loadableFileFactory;
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
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
		 */
		public function addFile(url:String, fileType:String = null,
											onOpen:Function=null, 
								   			onProgress:Function=null, 
								   			onComplete:Function=null, 
								   			onClose:Function=null,
								   			onIOError:Function=null,
								   			onSecurityError:Function=null):ILoadableFile
		{
			return addRequest(new URLRequest(url), fileType, onOpen, onProgress, onComplete, onClose, onIOError, onSecurityError);
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> from a <code>URLRequest</code> and add it to the current loading queue.
		 * 
		 * @param	request		The <code>URLRequest</code>.
		 * @param	fileType	The type of the file.
		 * @param	onOpen		The <code>Event.OPEN</code> listener.
		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.
		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.
		 * @param	onClose		The <code>Event.CLOSE</code> listener.
		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.
		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.
		 * @return	The created <code>ILoadableFile</code>.
		 */
		public function addRequest(request:URLRequest, fileType:String=null,
													   onOpen:Function=null, 
											   		   onProgress:Function=null, 
											   		   onComplete:Function=null, 
											   		   onClose:Function=null,
											   		   onIOError:Function=null,
											   		   onSecurityError:Function=null):ILoadableFile
		{
			var file:ILoadableFile = getLoadableFile(request, fileType);
			_factory.attachListeners(file,onOpen, onProgress, onComplete, onClose, onIOError, onSecurityError);
			_massLoader.addFile(file);
			return file;
		}

		/**
		 * Retrieves a <code>ILoadableFile</code> from a <code>URLRequest</code> and and a specified file type
		 * issued from the <code>LoadableFileType</code> constants.
		 * 
		 * @see	ch.capi.net.LoadableFileType	LoadableFileType
		 * @see	ch.capi.net.IFileSelector		IFileSelector
		 * @param	request		The <code>URLRequest</code>.
		 * @param	fileType	The type of the file.
		 * @return	The <code>ILoadableFile</code> created.
		 * @throws	ArgumentError	If the <code>fileType</code> is not valid.
		 */
		public function getLoadableFile(request:URLRequest, fileType:String=null):ILoadableFile
		{
			switch(fileType)
			{
				case LoadableFileType.BINARY:
				case LoadableFileType.TEXT:
				case LoadableFileType.VARIABLES:
					return _factory.createURLLoaderFile(request, fileType);
				
				case LoadableFileType.SWF:
					return _factory.createLoaderFile(request);
					
				case LoadableFileType.SOUND:
					return _factory.createSoundFile(request);
					
				case LoadableFileType.STREAM:
					return _factory.createURLStreamFile(request);
					
				case null:
					return _factory.createFile(request);
					
				default:
					throw new ArgumentError("File type '"+fileType+"' is not valid");
			}
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
		 * Clears the loading queue.
		 * 
		 * @see	ch.capi.net.IMassLoader#clear	IMassLoader.clear()
		 */
		public function clear():void
		{
			_massLoader.clear();
		}
	}
}
