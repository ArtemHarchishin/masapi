package
{
	import flash.display.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.xml.*;
	import fl.motion.*;
	
	import ch.capi.net.*;
	import ch.capi.display.AbstractDocument;
	
	public class AnimatorDocument extends AbstractDocument
	{
		public var animator:Animator;
		
		public override function initializeContext(loadableFile:ILoadableFile):void
		{
			super.initializeContext(loadableFile);
			
			//Retrieves the data
			var dataXml:ILoadableFile = loadableFile.properties.getValue("data");
			var picture:ILoadableFile = loadableFile.properties.getValue("picture");
			
			//Creates the picture
			var ldr:Loader = picture.getData("flash.display.Loader");
			addChild(ldr);
			
			//Creates the XMLDocument for the motion
			var xml:XML = dataXml.getData("XML");
			
			//Creates the Animator
			animator = new Animator(xml, ldr);
			animator.repeatCount = 0;
			animator.play();
		}
	}
}