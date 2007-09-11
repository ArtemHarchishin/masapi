package ch.capi.net
{
	import ch.capi.data.DictionnaryMap;
	import ch.capi.data.IMap;
	import ch.capi.errors.ExtensionNotDefinedError;
	
	import flash.net.URLRequest;
	
	/**
	 * Selector of <code>ILoadableFile</code> based on the extension.
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
		 */
		public function ExtensionFileSelector():void
		{
			_extensions.put("", LoadableFileType.STREAM);
			_extensions.put("swf", LoadableFileType.SWF);
			_extensions.put("txt", LoadableFileType.VARIABLES);
			_extensions.put("xml", LoadableFileType.TEXT);
			_extensions.put("mp3", LoadableFileType.SOUND);
			_extensions.put("jpg", LoadableFileType.BINARY); 
			_extensions.put("jpeg", LoadableFileType.BINARY);
			_extensions.put("gif", LoadableFileType.BINARY);
			_extensions.put("png", LoadableFileType.BINARY);
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
		 * @throws	flash.errors.ArgumentError	If the file type is invalid.
		 * @see		ch.capi.net.LoadableFileType	LoadableFileType.
		 */
		public function create(request:URLRequest, factory:LoadableFileFactory):ILoadableFile
		{
			var ext:String = getExtension(request);
			var type:String = _extensions.getValue(ext);
			
			if (type == null) throw new ExtensionNotDefinedError(ext);
			
			switch (type)
			{
				case LoadableFileType.TEXT:
				case LoadableFileType.VARIABLES:
				case LoadableFileType.BINARY:
					return factory.createURLLoaderFile(request, type);
					
				case LoadableFileType.SWF:
					return factory.createLoaderFile(request);
				
				case LoadableFileType.SOUND:
					return factory.createSoundFile(request);
					
				case LoadableFileType.STREAM:
					return factory.createURLStreamFile(request);
			}
			
			throw new ArgumentError("The file type '"+type+"' is invalid");
		}
		
		/**
		 * Retrieves the extension.
		 * 
		 * @param	request		The <code>URLRequest</code>.
		 * @return	The extension of the file specified by the url.
		 */
		public function getExtension(request:URLRequest):String
		{
			var u:String = request.url;
			
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