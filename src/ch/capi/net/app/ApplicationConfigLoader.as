package ch.capi.net.app{	import ch.capi.net.LoadableFileFactory;			import flash.net.URLRequest;	import flash.xml.XMLDocument;		import flash.events.Event;		import flash.net.URLLoaderDataFormat;		import flash.net.URLLoader;			/**	 * Utility class to load and parse an xml designed to be used by an <code>ApplicationMassLoader</code>.	 * 	 * @see			ch.capi.net.app.ApplicationFile			ApplicationFile	 * @see			ch.capi.net.app.ApplicationMassLoader	ApplicationMassLoader	 * @see			ch.capi.net.app.ApplicationFileParser	ApplicationFileParser	 * @author		Cedric Tabin - thecaptain	 * @version		1.0	 */	public class ApplicationConfigLoader extends URLLoader	{		//---------//		//Constants//		//---------//				/**		 * Defines the priority of the complete listener.		 */		private static const LISTENER_PRIORITY:int = 999;				//---------//		//Variables//		//---------//		private var _parser:ApplicationFileParser;		private var _xmlConfig:XMLDocument;		//-----------------//		//Getters & Setters//		//-----------------//		/**		 * Defines the <code>ApplicationFileParser</code> that will be used		 * when the file is loaded.		 */		public function get applicationFileParser():ApplicationFileParser { return _parser; }				/**		 * Defines the <code>IApplicationContext</code> in which the <code>ApplicationFiles</code>		 * have been created. This is a direct method to retrieve the		 * <code>ApplicationContext</code> of the <code>ApplicationFileParser</code>.		 */		public function get applicationContext():IApplicationContext { return _parser.applicationContext; }				/**		 * Defines the <code>LoadableFileFactory</code>. This is a direct method to retrieve the		 * <code>LoadableFileFactory</code> of the <code>ApplicationFileParser</code>.		 */		public function get loadableFileFactory():LoadableFileFactory { return _parser.loadableFileFactory; }		/**		 * Defines the <code>XMLDocument</code> that is given to the <code>fileParser</code>. This value is available only		 * once the file is loaded.		 */		public function get configuration():XMLDocument { return _xmlConfig; }				//-----------//		//Constructor//		//-----------//				/**		 * Creates a new <code>ApplicationConfigLoader</code>.		 * 		 * @param	parser	The <code>ApplicationFileParser</code> to use.		 */		public function ApplicationConfigLoader(parser:ApplicationFileParser):void		{			_parser = parser;			dataFormat = URLLoaderDataFormat.TEXT;			addEventListener(Event.COMPLETE, onFileLoaded, false, LISTENER_PRIORITY);		}				//--------------//		//Public methods//		//--------------//		/**		 * Creates a new <code>ApplicationConfigLoader</code> and a new <code>ApplicationContext</code>		 * with the specified name.		 * 		 * @param	contextName		The name of the <code>ApplicationContext</code>. The context must be inexistent.		 * @return	The created <code>ApplicationConfigLoader</code>.		 */		public static function create(contextName:String):ApplicationConfigLoader		{			var ctx:ApplicationContext = new ApplicationContext(contextName);			var parser:ApplicationFileParser = new ApplicationFileParser(ctx);			return new ApplicationConfigLoader(parser);		}		/**		 * Initializes the loading of the specified XML configuration (from the <code>URLRequest</code>) and once loaded,		 * put all the files in the specified <code>ApplicationMassLoader</code> and start it. If no		 * <code>ApplicationMassLoader</code> is specified, then a new one will be created.		 * 		 * @param	xmlRequest		The url of the XML configuration.		 * @param	appMassLoader	The <code>ApplicationMassLoader</code> to use.		 * @return	The <code>ApplicationMassLoaded</code> used.		 */		public function loadAll(xmlRequest:URLRequest, appMassLoader:ApplicationMassLoader=null):ApplicationMassLoader		{			if (appMassLoader == null) appMassLoader = new ApplicationMassLoader();						//special handler for the complete event			addEventListener(Event.COMPLETE, function(evt:Event):void { loadAllFiles(appMassLoader); }, false, -LISTENER_PRIORITY);			load(xmlRequest);						return appMassLoader;		}				/**		 * Initializes the loading of the specified XML configuration (from the <code>URLRequest</code>) and once loaded,		 * put the specified file in the <code>ApplicationMassLoader</code> and start it. If no		 * <code>ApplicationMassLoader</code> is specified, then a new one will be created.		 * 		 * @param	xmlRequest		The url of the XML configuration.		 * @param	fileName		The file to load.		 * @param	appMassLoader	The <code>ApplicationMassLoader</code> to use.		 * @return	The <code>ApplicationMassLoaded</code> used.		 */		public function loadFile(xmlRequest:URLRequest, fileName:String, appMassLoader:ApplicationMassLoader=null):ApplicationMassLoader		{			if (appMassLoader == null) appMassLoader = new ApplicationMassLoader();						//special handler for the complete event			addEventListener(Event.COMPLETE, function(evt:Event):void 			{				var file:ApplicationFile = applicationContext.getFile(fileName);				loadOneFile(appMassLoader, file);							}, false, -LISTENER_PRIORITY);						load(xmlRequest);						return appMassLoader;		}		//-----------------//		//Protected methods//		//-----------------//				/**		 * This method is called when the file is loaded.		 * 		 * @param	evt		The <code>Event</code> object.		 */		protected function onFileLoaded(evt:Event):void		{			//parses the XML			var xmlConfig:XMLDocument = new XMLDocument();			xmlConfig.ignoreWhite = true;        	xmlConfig.parseXML(this.data);        	_xmlConfig = xmlConfig;						//parses the files			_parser.parseNode(xmlConfig.firstChild);		}				/**		 * Once the loading and the parsing of the XML configuration is finished,		 * this method will be called if the <code>loadAll</code> method has intialized		 * the loading.		 * 		 * @param	appMassLoader		The <code>ApplicationMassLoader</code> to put the files in and start.		 * @see		#loadAll()			loadAll()		 */		protected function loadAllFiles(appMassLoader:ApplicationMassLoader):void		{			appMassLoader.addAll(applicationContext);			appMassLoader.start();		}				/**		 * Once the loading and the parsing of the XML configuration is finished,		 * this method will be called if the <code>loadFile</code> method has intialized		 * the loading.		 * 		 * @param	appMassLoader	The <code>ApplicationMassLoader</code> to put the files in and start.		 * @param 	file			The <code>ApplicationFile</code> to load.		 */		protected function loadOneFile(appMassLoader:ApplicationMassLoader, file:ApplicationFile):void		{			appMassLoader.addApplicationFile(file);			appMassLoader.start();		}				//---------------//		//Private methods//		//---------------//	}}