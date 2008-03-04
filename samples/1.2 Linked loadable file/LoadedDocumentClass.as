package
{
	import flash.events.*;
	import ch.capi.display.AbstractDocument;
	import ch.capi.net.*;
	
	public class LoadedDocumentClass extends AbstractDocument //you should alos simply implement ch.capi.core.IApplicationContext
	{
		public override function initializeContext(file:ILoadableFile):void
		{
			//call the method of AbstractDocument
			super.initializeContext(file);
			
			//just display the value
			var v:String = file.properties.getValue("sampleValue"); //or super.loadableFile.getValue(...)
			trace("This is the value (traced from the loaded SWF) : '"+v+"'");
		}
	}
}