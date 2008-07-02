package
{
	import ch.capi.display.AbstractDocument;
	import ch.capi.core.ApplicationMassLoader;
	import ch.capi.core.ApplicationFile;
	
	public class EngineDocument extends AbstractDocument
	{
		public static var lastApplicationFileLoaded:ApplicationFile		= null;
		public static var applicationMassLoader:ApplicationMassLoader 	= new ApplicationMassLoader();
		
		public static function loadFile(file:String):ApplicationFile
		{
			var f:ApplicationFile = ApplicationFile.getFile(file);
			if (f == null) throw new ArgumentError("File '"+file+"' is not defined");
			
			lastApplicationFileLoaded = f;
			
			if (applicationMassLoader.stateLoading)
			{
				applicationMassLoader.stop();
				applicationMassLoader.clear();
			}
			
			applicationMassLoader.addApplicationFile(f);
			applicationMassLoader.start();
			
			return f;
		}
	}
}