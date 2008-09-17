package
{
	import flash.events.*;
	import flash.display.*;
	import ch.capi.net.*;
	
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	public class PictureFile extends Sprite
	{
		public static const MAX_WIDTH:Number = 100;
		public static const MAX_HEIGHT:Number = 100;
		public static const PIC_PER_LINE:uint = 4;
		public static const MARGIN_X:Number = 10;
		public static const MARGIN_Y:Number = 10;
		
		private var _index:int;
		private var _file:ILoadableFile;
		private var _loader:Loader;
		
		public function PictureFile(file:ILoadableFile, index:int)
		{
			_file = file;
			_index = index;
			_loader = _file.getData("flash.display.Loader");
			_loader.contentLoaderInfo.addEventListener(Event.INIT, initEvent);
		}
		
		public function resize():void
		{
			//nothing to do
			if (width < MAX_WIDTH && height < MAX_HEIGHT) return;
			
			//resize the width
			if (width > height)
			{
				var rw:Number = height/width;
				width = MAX_WIDTH;
				height = MAX_WIDTH*rw;
			}
			
			//resize the height
			else
			{
				var rh:Number = width/height;
				height = MAX_HEIGHT;
				width = MAX_HEIGHT*rh;
			}
		}
		
		private function initEvent(evt:Event):void
		{
			addChild(_loader);
			resize();
			
			var modx:int = _index % PIC_PER_LINE;
			var mody:int = Math.floor(_index / PIC_PER_LINE);
			
			x = (MAX_WIDTH+MARGIN_X)*modx;
			y = (MAX_HEIGHT+MARGIN_Y)*mody;
			
			_loader.x = (MAX_WIDTH-_loader.x)/2;
			_loader.y = (MAX_HEIGHT-_loader.y)/2;
			
			var tx:Tween = new Tween(this, "x", Elastic.easeOut, -MAX_WIDTH-MARGIN_X, x, 0.4, true);
			var ty:Tween = new Tween(this, "y", Elastic.easeOut, -MAX_HEIGHT-MARGIN_Y, y, 0.6, true);
		}
	}
}