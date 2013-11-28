package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.geom.Matrix;
	
	public class BMPLoader extends Loader
	{
		private var _width:int;  /// temp variants, pass the parameter to the width and height
		private var _height:int;
		public var instance:Bitmap;
		
		public function BMPLoader(_request:URLRequest, _width:int, _height:int)
		{						
			this._width = _width;
			this._height = _height;
			instance = new Bitmap();	
			contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			load(_request)		
		}
		private function onLoaderComplete(e:Event):void
		{	
			var bmpdata:BitmapData = new BitmapData(width,height,true,0x00FFFFFF);
			bmpdata.draw(this);
			instance.bitmapData = bmpdata;	
			instance.scaleX = Number(_width)/width;
			instance.scaleY = Number(_height)/height;
		}	
	}
}