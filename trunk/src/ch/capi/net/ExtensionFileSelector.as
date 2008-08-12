package ch.capi.net
{
	import ch.capi.data.DictionnaryMap;
	import ch.capi.data.IMap;
	import ch.capi.errors.ExtensionNotDefinedError;
	
	import flash.net.URLRequest;
	
	/**
	 * Selector of <code>ILoadableFile</code> based on the extension.
	 * 
	 * @example
	 * Add/Modify an extension :
	 * <listing version="3.0">
	 * var selector:ExtensionFileSelector = new ExtensionFileSelector();
	 * selector.extensions.put("zip", LoadableFileType.BINARY);
	 * 
	 * var factory:LoadableFileFactory = new LoadableFileFactory(selector);
	 * var file:ILoadableFile = factory.create("myFile.zip"); //creates a binary URLLoader-based ILoadableFile
	 * </listing>
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class ExtensionFileSelector implements ILoadableFileSelector
	{
		//---------//
		//Variables//
		//---------//
		private var _extensions:IMap		= new DictionnaryMap(false);
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the mapping between the extensions and the file type issued from
		 * the <code>LoadableFileType</code> class constants.
		 * 
		 * @see	ch.capi.net.LoadableFileType	LoadableFileType
		 */
		public function get extensions():IMap { return _extensions; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ExtensionFileSelector</code> object.
		 * <p>The following extensions are defined by default :<br />
		 * <ul>
		 * 	<li><i>swf</i> as <code>LoadableFileType.SWF</code></li>
		 * 	<li><i>txt</i> as <code>LoadableFileType.VARIABLES</code></li>
		 * 	<li><i>xml</i> as <code>LoadableFileType.TEXT</code></li>
		 * 	<li><i>css</i> as <code>LoadableFileType.TEXT</code></li>
		 * 	<li><i>mp3</i> as <code>LoadableFileType.SOUND</code></li>
		 * 	<li><i>wav</i> as <code>LoadableFileType.SOUND</code></li>
		 * 	<li><i>jpg</i> as <code>LoadableFileType.BINARY</code></li>
		 * 	<li><i>jpeg</i> as <code>LoadableFileType.BINARY</code></li>
		 * 	<li><i>gif</i> as <code>LoadableFileType.BINARY</code></li>
		 * 	<li><i>png</i> as <code>LoadableFileType.BINARY</code></li>
		 * 	<li><i>php</i> as <code>LoadableFileType.TEXT</code></li>
		 * 	<li><i>asp</i> as <code>LoadableFileType.TEXT</code></li>
		 * </ul></p>
		 */
		public function ExtensionFileSelector():void
		{
			_extensions.put("", LoadableFileType.STREAM);
			_extensions.put("swf", LoadableFileType.SWF);
			_extensions.put("txt", LoadableFileType.VARIABLES);
			_extensions.put("xml", LoadableFileType.TEXT);
			_extensions.put("css", LoadableFileType.TEXT);
			_extensions.put("html", LoadableFileType.TEXT);
			_extensions.put("mp3", LoadableFileType.SOUND);
			_extensions.put("wav", LoadableFileType.SOUND);
			_extensions.put("jpg", LoadableFileType.BINARY); 
			_extensions.put("jpeg", LoadableFileType.BINARY);
			_extensions.put("gif", LoadableFileType.BINARY);
			_extensions.put("png", LoadableFileType.BINARY);
			_extensions.put("php", LoadableFileType.TEXT);
			_extensions.put("asp", LoadableFileType.TEXT);
		}

		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Creates a <code>ILoadableFile</code> using the specified <code>LoadableFileFactory</code>.
		 * 
		 * @param	request		The <code>URLRequest</code>.
		 * @param	factory		The <code>LoadableFileFactory</code>.
		 * @return	The created <code>ILoadableFile</code> object.
		 * @throws	ch.capi.errors.ExtensionNotDefinedError	If the extensions into the specified request was
		 * 			not found into the extensions map.
		 * @see		ch.capi.net.LoadableFileType	LoadableFileType.
		 */
		public function create(request:URLRequest, factory:LoadableFileFactory):ILoadableFile
		{
			var ext:String = getExtension(request);
			var type:String = _extensions.getValue(ext);
			
			if (type == null) throw new ExtensionNotDefinedError(ext);
			
			var file:ILoadableFile = factory.createFile(request, type);
			return file;
		}
		
		/**
		 * Retrieves the extension.
		 * 
		 * @param	request		The <code>URLRequest</code>.
		 * @return	The extension of the file specified by the url.
		 */
		public function getExtension(request:URLRequest):String
		{
			var u:String = request.url.toLowerCase();
			
			var a:int = u.indexOf("?");
			if (a != -1) u = u.substring(0, a);
			
			u = u.split("\\").join("/");
			if (u.charAt(u.length-1) == "/") u = u.substring(0, u.length-1);
			
			var s:int = u.lastIndexOf("/");
			if (s == u.length-1) return ""; //no file name => no extension
			if (s != -1) u = u.substring(s+1, u.length);
			
			var d:int = u.lastIndexOf(".");
			if (d == -1 || d == u.length-1) return ""; //no extension
			
			return u.substring(d+1, u.length);
		}
	}
}
