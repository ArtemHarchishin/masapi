package ch.capi.net.app 
{	import ch.capi.errors.DataError;		import ch.capi.net.files.URLLoaderFile;	
	import ch.capi.net.files.LoaderFile;	
	import ch.capi.net.IContextPolicy;	
	import ch.capi.net.policies.DefaultContextPolicy;		
	import ch.capi.utils.ParseUtils;		import ch.capi.errors.ParseError;
	import ch.capi.net.LoadableFileFactory;
	import ch.capi.net.ILoadableFile;

	import flash.xml.XMLDocument;		
	import flash.xml.XMLNode;
	import flash.net.URLVariables;
	
	/**
	 * Parser of <code>ApplicationFile</code> objects. The XMLSchema and a XML validator can be found
	 * <a href="http://www.astorm.ch/masapi/validator.php">here</a>.
	 * 
	 * @see		ch.capi.net.app.ApplicationFile			ApplicationFile
	 * @see		ch.capi.net.app.ApplicationMassLoader	ApplicationMassLoader
	 * @see		ch.capi.net.app.ApplicationConfigLoader	ApplicationConfigLoader	 * @author 	Cedric Tabin - thecaptain
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
		 * Defines the 'files' node name.
		 */
		private static const NODE_FILES:String = "files";
		
		/**
		 * Defines the 'variables' node name.
		 */
		private static const NODE_VARIABLES:String = "variables";
		
		/**
		 * Defines the 'dependencies' node name.
		 */
		private static const NODE_DEPENDENCIES:String = "dependencies";
		
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
		 * Defines the 'alwaysUseCache' attribute value.
		 */
		private static const ATTRIBUTE_ALWAYSUSECACHE_VALUE:String = "alwaysUseCache";
		
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
		
		/**
		 * Defines the 'priority' attribute value.
		 */
		private static const ATTRIBUTE_PRIORITY_VALUE:String = "priority";
		
		/**
		 * Defines the 'folder' node name.
		 */
		private static const NODE_FOLDER:String = "folder";
		
		/**
		 * Defines the 'group' node name.
		 */
		private static const NODE_GROUP:String = "group";
		
		/**
		 * Defines the 'path' attribute value.
		 */
		private static const ATTRIBUTE_FOLDER_PATH:String = "path";
		
		/**
		 * Defines the 'absolute' attribute value.
		 */
		private static const ATTRIBUTE_FOLDER_ABSOLUTE:String = "absolutePath";
		
		/**
		 * Defines the 'context' attribute value.
		 */
		private static const ATTRIBUTE_CONTEXT:String = "contextName";
		
		/**
		 * Defines the 'appDomain' attribute value.
		 */
		private static const ATTRIBUTE_DOMAIN:String = "appDomain";
		
		/**
		 * Defines the 'secDomain' attribute value.
		 */
		private static const ATTRIBUTE_SECURITY:String = "secDomain";
		
		//---------//
		//Variables//
		//---------//
		private var _loadableFileFactory:LoadableFileFactory;
		private var _applicationContext:IApplicationContext;
		private var _currentIndex:int;
		
		/**
		 * Defines a callback method that is called when an <code>ApplicationFile</code> is created. If this property is
		 * not <code>null</code> it will be called after the properties have initialized, but before the dependencies have been added.
		 * The signature of the method should be the following : <code>function(appFile:ApplicationFile, fileNode:XMLNode):void</code>.
		 */
		public var initializeFile:Function = null;
		
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
		 * Defines the <code>IApplicationContext</code>.
		 */
		public function get applicationContext():IApplicationContext { return _applicationContext; }
		public function set applicationContext(value:IApplicationContext):void { _applicationContext = value; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ApplicationFileParser</code> object.
		 * 
		 * @param	context					The <code>ApplicationContext</code>.
		 * @param	loadableFileFactory		The <code>LoadableFileFactory</code>. If not defined, then the 
		 * 									<code>LoadableFileFactory.defaultLoadableFileFactory</code> will be used.
		 * 
		 */
		public function ApplicationFileParser(context:IApplicationContext, loadableFileFactory:LoadableFileFactory=null):void
		{
			_loadableFileFactory = (loadableFileFactory==null) ? LoadableFileFactory.defaultLoadableFileFactory : loadableFileFactory;
			
			_applicationContext = context;
		}

		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Creates a new <code>ApplicationFileParser</code> using a new empty <code>ApplicationContext</code>.
		 * 
		 * @param	contextName				The name of the new <code>ApplicationContext</code>.
		 * @param	loadableFileFactory		The <code>LoadableFileFactory</code>. If not defined, then the 
		 * 									<code>LoadableFileFactory.defaultLoadableFileFactory</code> will be used.
		 * @return	The created <code>ApplicationFileParser</code>.
		 */
		public static function createWithNewContext(contextName:String, loadableFileFactory:LoadableFileFactory=null):ApplicationFileParser
		{
			var newContext:ApplicationContext = new ApplicationContext(contextName);
			return new ApplicationFileParser(newContext, loadableFileFactory); 
		}

		/**
		 * Parses the specified source <code>String</code>, using the specified <code>LoadableFileFactory</code> in
		 * a new <code>ApplicationContext</code>.
		 * 
		 * @param	source					The source <code>String</code> in <code>XML</code> format that matches the XMLSchema.
		 * @param	contextName				Defines the name of the <code>ApplicationContext</code>. If no context name is specified, then
		 * 									the global <code>ApplicationContext</code> will be used.
		 * @param	loadableFileFactory		The <code>LoadableFileFactory</code>. If not defined, then the 
		 * 									<code>LoadableFileFactory.defaultLoadableFileFactory</code> will be used.
		 * @return	The new <code>ApplicationContext</code> that contains all the parsed <code>ApplicationFile</code> instances.
		 * @throws	ch.capi.errors.DataError	If the <code>contextName</code> and the context attribute is <code>null</code>.
		 */
		public static function parse(source:String, contextName:String=null, loadableFileFactory:LoadableFileFactory=null):IApplicationContext
		{
			var doc:XMLDocument = new XMLDocument();
			doc.ignoreWhite = true;
			doc.parseXML(source);
			
			var ctxName:String = (contextName != null) ? contextName : doc.firstChild.attributes[ATTRIBUTE_CONTEXT];
			if (ctxName == null) throw new DataError("The context name is not specified");
			
			var context:ApplicationContext = new ApplicationContext(ctxName); 
			
			var parser:ApplicationFileParser = new ApplicationFileParser(context, loadableFileFactory);
			parser.parseNode(doc.firstChild);
			
			return parser.applicationContext;
		}

		/**
		 * Parse the specified <code>XMLNode</code>. The specified node must contains at least one subnode with all
		 * the files declaration. The second subnode will contains the dependencies.
		 * 
		 * @param	node	The <code>XMLNode</code> to parse.
		 * @param	ch.capi.errors.ParseError	If the node is invalid.
		 */
		public function parseNode(node:XMLNode):void
		{
			if(node.childNodes.length < 1 || node.childNodes.length > 3) throw new ParseError("parseNode", "Invalid node count : "+node.childNodes.length, node);
			
			var firstNode:XMLNode = node.firstChild;
			if (firstNode.nodeName == NODE_VARIABLES)
			{
				parseVariables(firstNode); //parses the variables
				parseFiles(node.childNodes[1]); //files are always parsed.
				if(node.childNodes.length == 3) parseDependencies(node.childNodes[2]);
			}
			else
			{
				parseFiles(node.childNodes[0]); //files are always parsed.
				if(node.childNodes.length == 2) parseDependencies(node.childNodes[1]);
			}
		}
		
		/**
		 * Parses the variables of the specified <code>XMLNode</code>.
		 * 
		 * @param	node		The <code>XMLNode</code>.
		 */
		public function parseVariables(node:XMLNode):void
		{
			if (node.nodeName != NODE_VARIABLES) throw new ArgumentError("Invalid node name '"+node.nodeName+"'");
			for each(var child:XMLNode in node.childNodes)
			{
				var name:String = child.attributes[ATTRIBUTE_NAME_VALUE];
				if (name == null) throw new ParseError("parseVariables", "The attribute '"+ATTRIBUTE_NAME_VALUE+"' is not defined", child);
				
				//if the value is not defined, then put an empty string, otherwise, take the node value
				var value:String = (child.firstChild != null) ? child.firstChild.nodeValue : "";
				
				//store the variable value
				putVariable(name, value);
			}
		}
		
		/**
		 * Parses the <code>ApplicationFile</code> of the specified <code>XMLNode</code>.
		 * 
		 * @param node	The <code>XMLNode</code>.
		 */
		public function parseFiles(node:XMLNode):void
		{
			if (node.nodeName != NODE_FILES) throw new ArgumentError("Invalid node name '"+node.nodeName+"'");
			
			//virtual bytes total
			if (node.attributes[ATTRIBUTE_VIRTUALBYTESTOTAL_VALUE] != null)
			{
				var valueVB:int = ParseUtils.parseUnsigned(node.attributes[ATTRIBUTE_VIRTUALBYTESTOTAL_VALUE]);
				if (!isNaN(valueVB)) loadableFileFactory.defaultVirtualBytesTotal = valueVB;
			}
			
			//use cache
			if (node.attributes[ATTRIBUTE_ALWAYSUSECACHE_VALUE] != null)
			{
				var valueUC:String = node.attributes[ATTRIBUTE_ALWAYSUSECACHE_VALUE];
				loadableFileFactory.alwaysUseCache = ParseUtils.parseBoolean(valueUC);
			}
			
			//base path
			if (node.attributes[ATTRIBUTE_BASEPATH_VALUE] != null)
			{
				var basePath:String = node.attributes[ATTRIBUTE_BASEPATH_VALUE];
				loadableFileFactory.basePath = basePath;
			}
			
			//root folder path
			var rootPath:String = "";
			if (node.attributes[ATTRIBUTE_FOLDER_PATH] != null)
			{
				rootPath = node.attributes[ATTRIBUTE_FOLDER_PATH];
				if (rootPath.length > 0 && rootPath.charAt(rootPath.length-1) != "/") rootPath += "/";
			}
			
			//domain & security policy
			if (node.attributes[ATTRIBUTE_DOMAIN] != null || node.attributes[ATTRIBUTE_SECURITY] != null)
			{
				var appDomain:String = node.attributes[ATTRIBUTE_DOMAIN];
				var secDomain:String = node.attributes[ATTRIBUTE_SECURITY];
				var policy:DefaultContextPolicy = new DefaultContextPolicy();
				
				if (appDomain != null) policy.defaultAppDomainPolicy = appDomain;
				if (secDomain != null) policy.defaultSecDomainPolicy = secDomain;
				
				loadableFileFactory.contextPolicy = policy;
			}
			
			//parse the sub nodes
			_currentIndex = 0;
			parseApplicationFiles(node, rootPath);
		}
		
		/**
		 * Parses the <code>ApplicationFile</code> dependencies of the specified <code>XMLNode</code>.
		 * 
		 * @param node	The <code>XMLNode</code>.
		 */
		public function parseDependencies(node:XMLNode):void
		{
			if (node.nodeName != NODE_DEPENDENCIES) throw new ArgumentError("Invalid node name '"+node.nodeName+"'");
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
		 * Put the specified variable and its value in the <code>LoadableFileFactory</code>.
		 * 
		 * @param	name	The variable name.
		 * @param	value	The variable value.
		 */
		protected function putVariable(name:String, value:String):void
		{
			loadableFileFactory.defaultVariables.put(name, value);
		}
		
		/**
		 * Creates a <code>ApplicationFile</code> from the <code>XMLNode</code>.
		 * 
		 * @param	node		The <code>XMLNode</code> to parse.
		 * @param	folderPath	The path to be added as prefix for the file URL.
		 * @return	The created <code>ApplicationFile</code>.
		 * @throws	ch.capi.errors.ParseError	If the url attribute is not defined.
		 */
		protected function createApplicationFile(node:XMLNode, folderPath:String):ApplicationFile
		{
			var name:String = node.attributes[ATTRIBUTE_NAME_VALUE];
			if (name == null || name.length == 0) name="$appFile_"+_currentIndex+"$";
		
			var appFile:ApplicationFile = new ApplicationFile(name, applicationContext);
			
			var url:String = node.attributes[ATTRIBUTE_URL_VALUE];
			var type:String = node.attributes[ATTRIBUTE_TYPE_VALUE];
			if (url != null && url.length > 0)
			{
				//checks if the path is absolute
				var isAbsolutePath:Boolean = false;
				if (node.attributes[ATTRIBUTE_FOLDER_ABSOLUTE] != null) isAbsolutePath = ParseUtils.parseBoolean(node.attributes[ATTRIBUTE_FOLDER_ABSOLUTE]);
				
				//update the url with the folder (if the path is not absolute)
				if (!isAbsolutePath) url = folderPath+url;

				//creation of the loadable file
				var appDomain:String = node.attributes[ATTRIBUTE_DOMAIN];
				var secDomain:String = node.attributes[ATTRIBUTE_SECURITY];
				var loadableFile:ILoadableFile = createLoadableFile(url, type, appDomain, secDomain);
				appFile.loadableFile = loadableFile;
				
				//attach the properties to the ILoadableFile
				for(var prop:String in node.attributes)
				{
					var dt:String = node.attributes[prop];
					loadableFile.properties.setValue(prop, dt);
				}
			}
			else
			{
				throw new ParseError("createApplicationFile", "The specified url is invalid for the file '"+name+"'");
			}
				
			//initialization
			initializeApplicationFile(appFile);
		
			//manual init
			if (initializeFile != null) initializeFile(appFile, node);
		
			return appFile;
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> object.
		 * 
		 * @param	url		The url.
		 * @param	type	The type issued from the <code>LoadableFileFactory</code> constants.
		 * @param	appDomainPolicy	The <code>ApplicationDomain</code> policy.
		 * @param	secDomainPolicy	The <code>SecurityDomain</code> policy.
		 * @return	The <code>ILoadableFile</code> created.
		 * 
		 * @see		ch.capi.utils.DomainUtils DomainUtils
		 */
		protected function createLoadableFile(url:String, type:String=null, appDomainPolicy:String=null, secDomainPolicy:String=null):ILoadableFile
		{
			var factory:LoadableFileFactory = _loadableFileFactory;
			var file:ILoadableFile = factory.createFile(url, type);
			
			//the policies are not defined, so simply create the file
			if (appDomainPolicy != null || secDomainPolicy != null)
			{
				var ctxPolicy:IContextPolicy = factory.contextPolicy;
				
				//updates the loaderContext of the loadable file
				if (file is LoaderFile) (file as LoaderFile).loaderContext = ctxPolicy.getLoaderContext(file, appDomainPolicy, secDomainPolicy);
				else if (file is URLLoaderFile) (file as URLLoaderFile).loaderContext = ctxPolicy.getLoaderContext(file, appDomainPolicy, secDomainPolicy);
				else
				{
					//the policies doesn't apply to the file...
					//throw an exception ??? -> mmmh no, it can be used as a property for another use
				}
			}
			
			return file;
		}
		
		/**
		 * Initialize the <code>ApplicationFile</code>. This method initialize the main properties of the 
		 * specified <code>ApplicationFile</code> and its <code>ILoadableFile</code>.
		 * 
		 * @param	appFile	The <code>ApplicationFile</code> to initialize.
		 * @throws	ch.capi.errors.ParseError	If there is a parse error.
		 */
		protected function initializeApplicationFile(appFile:ApplicationFile):void
		{
			var loadableFile:ILoadableFile = appFile.loadableFile;
			
			/*
			 * Initialize the ApplicationFile properties
			 */
			var g:String = loadableFile.properties.getValue(ATTRIBUTE_GLOBAL_VALUE);
			if (g != null) appFile.global = ParseUtils.parseBoolean(g);
			
			var y:String = loadableFile.properties.getValue(ATTRIBUTE_PRIORITY_VALUE);
			if (y != null) appFile.priority = ParseUtils.parseInteger(y);
			
			/*
			 * Initialize the ILoadableFile properties
			 */
			var p:String = loadableFile.properties.getValue(ATTRIBUTE_VIRTUALBYTESTOTAL_VALUE);
			if (p != null) loadableFile.virtualBytesTotal = ParseUtils.parseUnsigned(p);
			
			var c:String = loadableFile.properties.getValue(ATTRIBUTE_USECACHE_VALUE);	
			if (c != null) loadableFile.useCache = ParseUtils.parseBoolean(c);
			
			var n:String = loadableFile.properties.getValue(ATTRIBUTE_NETSTATE_VALUE);
			if (n != null) loadableFile.netState = n;
			
			var rm:String = loadableFile.properties.getValue(ATTRIBUTE_REQUEST_METHOD_VALUE);
			if (rm != null) loadableFile.urlRequest.method = rm.toUpperCase();
			
			var rd:String = loadableFile.properties.getValue(ATTRIBUTE_REQUEST_DATA_VALUE);
			if (rd != null)
			{
				try
				{
					var rv:URLVariables = new URLVariables(rd);
					loadableFile.urlRequest.data = rv;
				}
				catch(e:Error)
				{
					//oh ! the value couldn't be parsed as URLVariables...
					loadableFile.urlRequest.data = rd;
				}
			}
		}
		
		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 */
		private function parseApplicationFiles(node:XMLNode, folderPath:String):void
		{
			var n:Array = node.childNodes;
			for each(var cn:XMLNode in n)
			{
				if (cn.nodeName == NODE_FOLDER)
				{
					//there is a folder ! Retrieve the path and loop recursively over it.
					var subPath:String = cn.attributes[ATTRIBUTE_FOLDER_PATH];
					if (subPath != null && subPath.length > 0)
					{
						//put the '/' at the end of the subPath
						if (subPath.charAt(subPath.length-1) != "/") subPath += "/";
						
						//check if the path must be considered as absolute
						var isAbsolutePath:Boolean = false;
						if (cn.attributes[ATTRIBUTE_FOLDER_ABSOLUTE] != null) isAbsolutePath = ParseUtils.parseBoolean(cn.attributes[ATTRIBUTE_FOLDER_ABSOLUTE]);
						if (!isAbsolutePath) subPath = folderPath+subPath;
		
						//creates the application files recursively
						parseApplicationFiles(cn, subPath); 
					}
				}
				else
				{
					//the node is a file, so create it !
					createApplicationFile(cn, folderPath);
					_currentIndex++;
				}
			}
		}
		
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
		
			var app:ApplicationFile = applicationContext.getFile(name);
			if (node.nodeName == NODE_GROUP && app != null) throw new ParseError("getApplicationFile", "There is already a group/file with the name '"+name+"'");
			else if (node.nodeName != NODE_GROUP && app == null) throw new ParseError("getApplicationFile", "The file named '"+name+"' does not exist");
			else if (app == null) app = new ApplicationFile(name, applicationContext); //this is a group => create an empty ApplicationFile
			
			return app;
		}	}}