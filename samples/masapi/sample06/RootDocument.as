package masapi.sample06
{
	import ch.capi.events.MassLoadEvent;	
	import ch.capi.net.policies.DefaultLoadPolicy;	
	import ch.capi.net.ILoadPolicy;	
	
	import masapi.Constants;	
	
	import flash.text.TextFormat;	
	import flash.text.TextFieldAutoSize;	
	import flash.net.URLVariables;	
	import flash.text.TextField;	
	import flash.display.Loader;	
	import flash.events.Event;	
	import flash.display.Sprite;	
	
	import ch.capi.net.CompositeMassLoader;
	import ch.capi.net.ILoadableFile;
	import ch.capi.net.DataType;
	
	//SWF configuration
	[SWF(width="500", height="500", frameRate="30", backgroundColor="#FFFFFF")]
	
	/**
	 * This is a simple demo of the usage of the <code>CompositeMassLoader</code>
	 * class.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class RootDocument extends Sprite 
	{
		//---------//
		//Variables//
		//---------//
		private var _compositeMassLoader:CompositeMassLoader = new CompositeMassLoader();
		private var _pictureFile:ILoadableFile;
		private var _txtFile:ILoadableFile;

		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>SimpleMassLoader</code> object.
		 */
		public function RootDocument():void
		{
			//listening to the complete event
			_compositeMassLoader.addEventListener(MassLoadEvent.FILE_OPEN, onFileOpen);
			_compositeMassLoader.addEventListener(MassLoadEvent.FILE_CLOSE, onFileClose);
			_compositeMassLoader.addEventListener(Event.COMPLETE, onMassLoadComplete);
			
			//put the files into the loading queue and start the loading
			init();
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		protected function onFileOpen(evt:MassLoadEvent):void
		{
			 trace("OPEN : "+evt.getFile().urlRequest.url);
		}
		
		protected function onFileClose(evt:MassLoadEvent):void
		{
			trace("CLOSE : "+evt.getFile().urlRequest.url);	
		}
		
		protected function onMassLoadComplete(evt:Event):void
		{
			 //retrieves the data
			 var picture:Loader = _pictureFile.getData(DataType.LOADER);
			 var variables:URLVariables = _txtFile.getData(DataType.URL_VARIABLES);
			 
			 //extract the variables
			 var title:String = variables.title;
			 var text:String = variables.text;
			 
			 //put the text on the stage
			 var titleField:TextField = createSimpleField();
			 titleField.text = title;
			 addChild(titleField);
			 
			 var textField:TextField = createSimpleField();
			 textField.text = text;
			 textField.y = titleField.height+5;
			 addChild(textField);
			 
			 //and finally put the picture on the stage
			 picture.y = textField.y + textField.height + 5;
			 addChild(picture);
		}
		
		protected function createSimpleField():TextField
		{
			//create a new TextField
			var field:TextField = new TextField();
			field.width = 200;
			field.height = 20;
			field.multiline = true;
			field.autoSize = TextFieldAutoSize.LEFT;
			
			//a simple TextFormat
			var format:TextFormat = new TextFormat();
			format.color = 0;
			format.font = "Arial";
			field.defaultTextFormat = format;
			
			return field;
		}

		//---------------//
		//Private methods//
		//---------------//

		private function init():void
		{
			//creates the variables
			Constants.putConstants(_compositeMassLoader.loadableFileFactory.defaultVariables);
			
			//put the files into the loading queue
			_pictureFile = _compositeMassLoader.addFile("${PICTURES}/flash.jpg");
			_txtFile = _compositeMassLoader.addFile("${TXT}/variables.txt");
			
			/*
			 * retrieves the policy. By default, the ILoadPolicy of a CompositeMassLoader is
			 * an instance of DefaultLoadPolicy.
			 */ 
			var policy:ILoadPolicy = _compositeMassLoader.massLoader.loadPolicy;
			if (policy is DefaultLoadPolicy)
			{
				//just cast it :)
				var defaultPolicy:DefaultLoadPolicy = policy as DefaultLoadPolicy;
				
				/*
				 * The reloadTimes property defines how many times the massloader must try to
				 * download a specific file. By default, this value is set to 1. Here we want 
				 * that it retries 3 times before continuing...
				 * A value of zero means that the massloader will try to reload the file as long
				 * as the download is not successful.
				 */
				defaultPolicy.reloadTimes = 3;
				
				//add an inexistant file to show how it works !
				_compositeMassLoader.addFile("anInexistantFile.swf");
			}
			
			//starts the loading
			_compositeMassLoader.start();
		}
	}
}