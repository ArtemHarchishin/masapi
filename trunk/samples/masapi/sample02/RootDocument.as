package masapi.sample02{	import masapi.Constants;			import ch.capi.data.IMap;		import ch.capi.net.LoadableFileFactory;			import flash.text.TextFormat;		import flash.text.TextFieldAutoSize;		import flash.net.URLVariables;		import flash.text.TextField;		import flash.display.Loader;		import flash.events.Event;		import flash.display.Sprite;			import ch.capi.net.CompositeMassLoader;	import ch.capi.net.ILoadableFile;	import ch.capi.net.DataType;		//SWF configuration	[SWF(width="500", height="500", frameRate="30", backgroundColor="#FFFFFF")]		/**	 * This sample is based on the sample01. It only uses dynamic URLs to load the	 * files with the CompositeMassLoader (see the <code>init()</code> method).	 * 	 * @author		Cedric Tabin - thecaptain	 * @version		1.0	 */	public class RootDocument extends Sprite 	{		//---------//		//Variables//		//---------//				/*		 * When a CompositeMassLoader is used into a class, it is important to		 * keep a reference on it, for example with an instance variable. Otherwise		 * the Garbage Collector will kill the instance an no more event will be 		 * dispatched...		 */		private var _compositeMassLoader:CompositeMassLoader = new CompositeMassLoader();		/*		 * Those two variables are used for the data retrieval once the massive loading		 * is complete (see the init() method).		 */		private var _pictureFile:ILoadableFile;		private var _xmlFile:ILoadableFile;		//-----------//		//Constructor//		//-----------//				/**		 * Creates a new <code>SimpleMassLoader</code> object.		 */		public function RootDocument():void		{			//listening to the complete event			_compositeMassLoader.addEventListener(Event.COMPLETE, onMassLoadComplete);						//put the files into the loading queue and start the loading			init();		}				//-----------------//		//Protected methods//		//-----------------//				protected function onMassLoadComplete(evt:Event):void		{			/*			 * When the code here is executed, that means that all the files have been			 * loaded (maybe not successfully). So, if there was no error, the we can			 * simply handle our data !			 */				 			 //retrieves the data			 var picture:Loader = _pictureFile.getData(DataType.LOADER);			 var variables:URLVariables = _xmlFile.getData(DataType.URL_VARIABLES);			 			 //extract the variables			 var title:String = variables.title;			 var text:String = variables.text;			 			 //put the text on the stage			 var titleField:TextField = createSimpleField();			 titleField.text = title;			 addChild(titleField);			 			 var textField:TextField = createSimpleField();			 textField.text = text;			 textField.y = titleField.height+5;			 addChild(textField);			 			 //and finally put the picture on the stage			 picture.y = textField.y + textField.height + 5;			 addChild(picture);			 			 /*			  * The piece of code here simply shows the difference between the			  * specified URL and the used url to load a file. 			  */			 trace("Dynamic URL of the picture : " + _pictureFile.urlRequest.url);			 trace("Real URL of the picture : "+_pictureFile.fixedRequest.url);		}		protected function createSimpleField():TextField		{			//create a new TextField			var field:TextField = new TextField();			field.width = 200;			field.height = 20;			field.multiline = true;			field.autoSize = TextFieldAutoSize.LEFT;						//a simple TextFormat			var format:TextFormat = new TextFormat();			format.color = 0;			format.font = "Arial";			field.defaultTextFormat = format;						return field;		}		//---------------//		//Private methods//		//---------------//		private function init():void		{			//retrieves the IMap that contains the variables for the URLs			var factory:LoadableFileFactory = _compositeMassLoader.loadableFileFactory;			var variables:IMap = factory.defaultVariables;						//and then put some variables into it (issued from the constants)			//    Note : for further samples, the method Constants.putConstants() will			//			 used to simplify the code.			variables.put("PICTURES", Constants.PICTURES_PATH);			variables.put("XML", Constants.XML_PATH);			variables.put("TXT", Constants.TXT_PATH);						/*			 * Now we can add the files into the loading queue. As there are 3 variables			 * defined (PICTURES, XML, TXT), we can use it into the URLs using the 			 * following format : ${VARIABLE_NAME} ==> ${PICTURES} will be replaced by the			 * value contained into Constants.PICTURES_PATH.			 */			_pictureFile = _compositeMassLoader.addFile("${PICTURES}/flash.jpg");			_xmlFile = _compositeMassLoader.addFile("${TXT}/variables.txt");						//starts the loading			_compositeMassLoader.start();		}	}}