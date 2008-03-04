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
			var dataXml:URLLoader = loadableFile.properties.getValue("data");
			var picture:URLLoader = loadableFile.properties.getValue("picture");
			
			//Creates the picture
			var ldr:Loader = new Loader();
			ldr.loadBytes(picture.data);
			addChild(ldr);
			
			//Creates the XMLDocument for the motion
			var xmlDoc:XMLDocument = new XMLDocument();
			xmlDoc.ignoreWhite = true;
			xmlDoc.parseXML(dataXml.data);
			var xml:XML = new XML(xmlDoc);
			
			//Creates the Animator
			animator = new Animator(xml, ldr);
			animator.repeatCount = 0;
			animator.play();
		}
	}
}