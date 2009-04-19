package masapi.sample05
{
	import ch.capi.net.LoadableFileType;		
	import ch.capi.net.ILoadableFile;		import ch.capi.net.CompositeMassLoader;		
	
	import masapi.Constants;	
	
	import flash.display.Sprite;	
	import flash.display.Loader;	
	
	//SWF configuration
	[SWF(width="500", height="500", frameRate="30", backgroundColor="#FFFFFF")]
	
	/**
	 * Root document of the main SWF.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class RootDocument extends Sprite
	{
		//---------//
		//Constants//
		//---------//
		
		/**
		 * Defines the name of the SWF to load.
		 */
		private static const SUB_SWF_FILE:String = "sample05_sub.swf";
		
		//---------//
		//Variables//
		//---------//
		
		/**
		 * Defining the CompositeMassLoader. It is important to see that a name is given
		 * to it and that's a sequential MassLoader (files are loaded one-by-one in the
		 * priority order).
		 */
		private var _compositeMassLoader:CompositeMassLoader = new CompositeMassLoader(SampleConstants.MASSLOADER_NAME, 1);

		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>RootDocument</code> object.
		 */
		public function RootDocument():void
		{ 
			//initializes the loading
			init();
		}
		
		//---------------//
		//Private methods//
		//---------------//

		private function init():void
		{
			//creates the variables
			Constants.putConstants(_compositeMassLoader.loadableFileFactory.defaultVariables);
			
			/*
			 * Put the sub-swf into the loading queue at the LOWEST priority.
			 * I also specify the type of the file (see below) to ensure that I have a Loader-based
			 * ILoadableFile. But by default, a null value would have the same behavior...
			 */
			var subSWF:ILoadableFile = _compositeMassLoader.addFile(SUB_SWF_FILE, LoadableFileType.SWF, 0);
			
			/*
			 * As we want to display it directly, put the swf into the display list. We can't
			 * use the getData() method because an error would be thrown (data not loaded)...
			 * So in that case, we know that the loadManagerObject will be a Loader (default for SWF),
			 * so we can directly access it and add it into the display list.
			 */
			var subLoader:Loader = subSWF.loadManagerObject as Loader;
			addChild(subLoader);
			
			//put the files into the loading queue
			_compositeMassLoader.addFile("${XML}/anim.xml", null, 4);
			_compositeMassLoader.addFile("${PICTURES}/flash.jpg", null, 4);
			_compositeMassLoader.addFile("${TXT}/variables.txt", null, 5);
			_compositeMassLoader.addFile("${PICTURES}/GNOME-GreenLandscape.jpg", null, 3);
			
			//starts the loading
			_compositeMassLoader.start();
		}
	}
}