package ch.capi.net.app 
{
	import ch.capi.errors.ParseError;
	import ch.capi.net.LoadableFileFactory;
	import ch.capi.net.ILoadableFile;
	
	import flash.xml.XMLNode;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	/**
	 * Parser of <code>ApplicationFile</code> objects. The XMLSchema and a XML validator can be found
	 * <a href="http://www.astorm.ch/masapi/validator.php">here</a>.
	 * 
	 * @see		ch.capi.net.app.ApplicationFile			ApplicationFile
	 * @see		ch.capi.net.app.ApplicationMassLoader	ApplicationMassLoader	 * @author 	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public class ApplicationFileParser 
	{
		//---------//
		//Constants//
		//---------//
		
		/**
		 * Defines the 'file' node name.
		 */
		private static const NODE_FILE:String = "file";
		
		/**
		 * Defines the 'name' attribute value.
		 */
		private static const ATTRIBUTE_NAME_VALUE:String = "name";
		
		/**
		 * Defines the 'global' attribute value.
		 */
		private static const ATTRIBUTE_GLOBAL_VALUE:String = "global";
		
		/**
		 * Defines the 'url' attribute value.
		 */
		private static const ATTRIBUTE_URL_VALUE:String = "url";
		
		/**
		 * Defines the 'type' attribute value.
		 */
		private static const ATTRIBUTE_TYPE_VALUE:String = "type";
		
		/**
		 * Defines the 'requestData' attribute value.
		 */
		private static const ATTRIBUTE_REQUEST_DATA_VALUE:String = "requestData";
		
		/**
		 * Defines the 'requestMethod' attribute value.
		 */
		private static const ATTRIBUTE_REQUEST_METHOD_VALUE:String = "requestMethod";
		
		/**
		 * Defines the 'virtualBytesTotal' attribute value.
		 */
		private static const ATTRIBUTE_VIRTUALBYTESTOTAL_VALUE:String = "virtualBytesTotal";
		
		/**
		 * Defines the 'useCache' attribute value.
		 */
		private static const ATTRIBUTE_USECACHE_VALUE:String = "useCache";
		
		/**
		 * Defines the 'netState' attribute value.
		 */
		private static const ATTRIBUTE_NETSTATE_VALUE:String = "netState";
		
		/**
		 * Defines the 'basePath' attribute value.
		 */
		private static const ATTRIBUTE_BASEPATH_VALUE:String = "basePath";
		
		//---------//
		//Variables//
		//---------//
		private var _loadableFileFactory:LoadableFileFactory;
		private var _applicationContext:ApplicationContext;
		private var _currentIndex:int;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the <code>LoadableFileFactory</code> to use to create the <code>ILoadableFile</code> objects.
		 */
		public function get loadableFileFactory():LoadableFileFactory { return _loadableFileFactory; }
		public function set loadableFileFactory(value:LoadableFileFactory):void
		{
			if (value == null) throw new ArgumentError("value is not defined"); 
			_loadableFileFactory = value;
		}
		
		/**
		 * Defines the <code>ApplicationContext</code>.
		 */
		public function get applicationContext():ApplicationContext { return _applicationContext; }
		public function set applicationContext(value:ApplicationContext):void { _applicationContext = value; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ApplicationFileParser</code> object.
		 * 
		 * @param	loadableFileFactory		The <code>LoadableFileFactory</code>.
		 * @param	context					The <code>ApplicationContext</code>. If not defined, then the global <code>ApplicationContext</code>
		 * 									will be used.
		 */
		public function ApplicationFileParser(loadableFileFactory:LoadableFileFactory=null, context:ApplicationContext=null):void
		{
			_loadableFileFactory = (loadableFileFactory==null) ? new LoadableFileFactory() : loadableFileFactory;
			
			if (context == null) context = ApplicationContext.getGlobalContext();
			_applicationContext = context;
		}

		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Parse the specified <code>XMLNode</code>. The specified node must contains at least one subnode will al
		 * the files declaration. The second subnode will contains the dependencies.
		 * 
		 * @param	node	The <code>XMLNode</code> to parse.
		 * @param	ch.capi.errors.ParseError	If the node is invalid.
		 */
		public function parse(node:XMLNode):void
		{
			if(node.childNodes.length < 1 || node.childNodes.length > 2) throw new ParseError("parse", "Invalid node count : "+node.childNodes.length, node);
			
			parseFiles(node.childNodes[0]); //files are always parsed.
			if(node.childNodes.length == 2) parseDependencies(node.childNodes[1]);
		}
		
		/**
		 * Parses the <code>ApplicationFile</code> of the specified <code>XMLNode</code>.
		 * 
		 * @param node	The <code>XMLNode</code>.
		 */
		public function parseFiles(node:XMLNode):void
		{
			//virtual bytes total
			if (node.attributes[ATTRIBUTE_VIRTUALBYTESTOTAL_VALUE] != null)
			{
				var valueVB:int = parseInt(node.attributes[ATTRIBUTE_VIRTUALBYTESTOTAL_VALUE]);
				if (!isNaN(valueVB)) loadableFileFactory.defaultVirtualBytesTotal = valueVB;
			}
			
			//use cache
			if (node.attributes[ATTRIBUTE_USECACHE_VALUE] != null)
			{
				var valueUC:String = node.attributes[ATTRIBUTE_USECACHE_VALUE];
				loadableFileFactory.defaultUseCache = !(valueUC.toLowerCase() == "false");
			}
			
			//base path
			if (node.attributes[ATTRIBUTE_BASEPATH_VALUE] != null)
			{
				var basePath:String = node.attributes[ATTRIBUTE_BASEPATH_VALUE];
				loadableFileFactory.basePath = basePath;
			}
			
			//parse the sub nodes
			_currentIndex = 0;
			var n:Array = node.childNodes;
			for each(var cn:XMLNode in n)
			{
				createApplicationFile(cn);
				_currentIndex++;
			}
		}
		
		/**
		 * Parses the <code>ApplicationFile</code> dependencies of the specified <code>XMLNode</code>.
		 * 
		 * @param node	The <code>XMLNode</code>.
		 */
		public function parseDependencies(node:XMLNode):void
		{
			var n:Array = node.childNodes;
			for each(var cn:XMLNode in n)
			{
				var app:ApplicationFile = getApplicationFile(cn);
				parseFileDependency(app, cn);
			}
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Creates a <code>ApplicationFile</code> from the <code>XMLNode</code>.
		 * 
		 * @param	node		The <code>XMLNode</code> to parse.
		 * @return	The created <code>ApplicationFile</code>.
		 */
		protected function createApplicationFile(node:XMLNode):ApplicationFile
		{
			var n:String = node.attributes[ATTRIBUTE_NAME_VALUE];
			if (n == null || n.length == 0) n="$appFile_"+_currentIndex+"$";
		
			var a:ApplicationFile = new ApplicationFile(n, null, applicationContext);
			
			var u:String = node.attributes[ATTRIBUTE_URL_VALUE];
			var t:String = node.attributes[ATTRIBUTE_TYPE_VALUE];
			if (u != null && u.length > 0)
			{
				var lf:ILoadableFile = createLoadableFile(u, t);
				a.loadableFile = lf;
				
				//attach the properties to the ILoadableFile
				for(var prop:String in node.attributes)
				{
					var dt:String = node.attributes[prop];
					lf.properties.put(prop, dt);
					
					//if this is the 'requestData' property, then attribute it to the data property of the URLRequest object
					if (prop == ATTRIBUTE_REQUEST_DATA_VALUE)
					{
						try
						{
							var rv:URLVariables = new URLVariables(dt);
							lf.urlRequest.data = rv;
						}
						catch(e:Error)
						{
							//oh ! the value couldn't be parsed as URLVariables...
							lf.urlRequest.data = dt;
						}
					}
					
					//if this is the 'requestMethod' property, then attribute it to the method property of the URLRequest object
					if (prop == ATTRIBUTE_REQUEST_METHOD_VALUE)
					{
						lf.urlRequest.method = dt.toUpperCase();
					}
				}
				
				//initialization
				initializeLoadableFile(lf);
			}
			
			var g:String = node.attributes[ATTRIBUTE_GLOBAL_VALUE];
			a.global = (g == true.toString());
		
			return a;
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> object.
		 * 
		 * @param	url		The url.
		 * @param	type	The type issued from the <code>LoadableFileFactory</code> constants.
		 * @return	The <code>ILoadableFile</code> created.
		 */
		protected function createLoadableFile(url:String, type:String=null):ILoadableFile
		{
			var lf:LoadableFileFactory = _loadableFileFactory;
			return lf.createFile(url, type);
		}
		
		/**
		 * Initialize the <code>ILoadableFile</code>. This method initialize the <code>virtualBytesTotal</code>,
		 * <code>useCache</code> and <code>netState</code> values if they are defined into the <code>properties</code>
		 * map of the <code>ILoadableFile</code>.
		 * 
		 * @param	file	The <code>ILoadableFile</code> to initialize.
		 */
		protected function initializeLoadableFile(file:ILoadableFile):void
		{
			var p:* = file.properties.getValue(ATTRIBUTE_VIRTUALBYTESTOTAL_VALUE);
			if (p != null && !isNaN(p)) file.virtualBytesTotal = parseInt(p);
			
			var c:* = file.properties.getValue(ATTRIBUTE_USECACHE_VALUE);
			if (c != null) file.useCache = (c==false.toString());
			
			var n:* = file.properties.getValue(ATTRIBUTE_NETSTATE_VALUE);
			if (n != null) file.netState = n;
		}
		
		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 */
		private function parseFileDependency(file:ApplicationFile, node:XMLNode):void
		{
			var n:Array = node.childNodes;
			for each(var cn:XMLNode in n)
			{
				if (cn.nodeName == NODE_FILE)
				{
					var app:ApplicationFile = getApplicationFile(cn);
					file.addDependency(app);
					
					//recursive parsing
					if (cn.hasChildNodes()) parseFileDependency(app, cn);
				}
				else
				{
					throw new ParseError("parseFileDependency", "The node is invalid (only '"+NODE_FILE+"' allowed) : " + cn);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function getApplicationFile(node:XMLNode):ApplicationFile
		{
			var name:String = node.attributes[ATTRIBUTE_NAME_VALUE];
			if (name == null || name.length == 0) throw new ParseError("getApplicationFile", "Attribute '"+ATTRIBUTE_NAME_VALUE+"' not defined", node);
			
			var app:ApplicationFile = ApplicationFile.get(name);
			if (app == null) throw new ParseError("getApplicationFile", "The file named '"+name+"' does not exist");
			
			return app;
		}	}}