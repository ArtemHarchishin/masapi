package masapi.sample07b
{
	import masapi.sample07.PictureBox;
	import ch.capi.net.ILoadableFile;
	import ch.capi.events.MassLoadEvent;
	import ch.capi.net.app.ApplicationMassLoader;
	import flash.net.URLRequest;

	import ch.capi.data.IMap;
	import ch.capi.utils.VariableReplacer;
	import masapi.Constants;
	import ch.capi.net.app.ApplicationConfigLoader;
	import flash.display.Sprite;
	
	//SWF configuration
	[SWF(width="600", height="300", frameRate="30", backgroundColor="#FFFFFF")]
	
	/**
	 * This is a easier way to load all the files within the ApplicationConfigLoader.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class RootDocument extends Sprite
	{
		//---------//
		//Constants//
		//---------//
		public static const CONTEXT:String = "sample07";
		public static const CONFIGURATION_FILE:String = "${"+Constants.XML_NAME+"}/clouds.xml";
		
		//---------//
		//Variables//
		//---------//
		private var _configLoader:ApplicationConfigLoader;
		private var _appLoader:ApplicationMassLoader = new ApplicationMassLoader(1);
		private var _pictures:Array = new Array();
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>RootDocument</code> object.
		 */
		public function RootDocument():void
		{
			//Put the listener to handle the loading of a picture
			_appLoader.addEventListener(MassLoadEvent.FILE_CLOSE, onPictureLoaded);
			
			/*
			 * creates the loader that will handle all the loading and parsing
			 * of an application configuration defined into a XML.
			 */
			_configLoader = ApplicationConfigLoader.create(CONTEXT);
			
			/*
			 * put the variables into the factory. This piece of code avoid the definition
			 * of each constants into the XML. Usually you would use the <variables> note into
			 * the XML configuration...
			 */
			var variables:IMap = _configLoader.loadableFileFactory.defaultVariables;
			Constants.putConstants(variables);
			
			//use the replacer to retrieve the final URL
			var configUrl:String = VariableReplacer.replace(CONFIGURATION_FILE, variables);
			
			//and finally load the configuration file
			_configLoader.loadAll(new URLRequest(configUrl), _appLoader);
		}

		//-----------------//
		//Protected methods//
		//-----------------//
		
		protected function onPictureLoaded(evt:MassLoadEvent):void
		{
			//creates the box for the picture
			var file:ILoadableFile = evt.getFile();
			var pb:PictureBox = new PictureBox(file);
			
			//sets the position of the picture
			var index:int = _pictures.length;
			var row:int = Math.floor(index/4);
			var column:int = index%4;
			
			pb.x = (PictureBox.SIZE+5)*column;
			pb.y = (PictureBox.SIZE+5)*row;
			
			//finalize...
			_pictures.push(pb);
			addChild(pb);
		}
	}
}