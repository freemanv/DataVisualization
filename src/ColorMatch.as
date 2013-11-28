package {

	import flare.animate.Tween;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	[SWF(width="800", height="600", backgroundColor="#ffffff", frameRate="30")]
	public class ColorMatch extends Sprite
	{
		var circle_pos_x:int;
		var circle_pos_y:int;
		var pickcolor_circle:Sprite;
		var rotate_circle:Sprite;
		var color_circle:Sprite;
		var color_circle_bmpdate:BitmapData;  /// used to get pixel value
		var move_circle:BMPLoader;
		var move_circle_pos_x:Number;
		var move_circle_pos_y:Number;
		var move_circle_R:Number;         
		var current_angle:Number;        // 当前衰减圆剩下的角度
		var current_rotate_color:Number; // 当前衰减圆的颜色
		var current_pick_color:Number;  // 当前用户鼠标所在位置的颜色，没有点击鼠标的
		var chosen_color:Number;  /// 当前用户点击鼠标选择了的颜色
		var timer:Timer;      // 刷新衰减圆动画帧
		var show_result_timer:Timer;      // 显示结果几秒钟
		var game_playing:Boolean;  // indicate if the game is playing
		var start_text:TextField;  /// text to be showed before playing game
		var result_text:TextField;  /// text to show the result
		
		
		public function ColorMatch()
		{
			/// initial parameter
			current_angle = 360;
			current_rotate_color = 0x000000;
			current_pick_color = 0xff0000;
			chosen_color = 0x000000;
			circle_pos_x = 200;
			circle_pos_y = 300;
			game_playing = false;
			rotate_circle = new Sprite();
			pickcolor_circle = new Sprite();
			color_circle = new Sprite();
			color_circle_bmpdate = new BitmapData(1000,1000);
			move_circle = new BMPLoader(new URLRequest("C:/Users/T@T/Desktop/move_circle.png"), 23.6, 23.6);
			move_circle.instance.x = -1000;
			move_circle.instance.y = -1000;
			///
			drawColorRing(color_circle,circle_pos_x,circle_pos_y);		
			move_circle_R = 175+11.8;
			color_circle_bmpdate.draw(color_circle);	
				
			// initial the start text
			var textfmt:TextFormat = new TextFormat();
			textfmt.color = 0x000000;
			textfmt.size = 30;
			start_text = new TextField();
			start_text.x = circle_pos_x-50;
			start_text.y = circle_pos_y-23;
			start_text.text = "Click to Start!";
			start_text.setTextFormat(textfmt);
			start_text.autoSize = TextFieldAutoSize.CENTER;
			// initial the result text
			result_text = new TextField();
			result_text.x = circle_pos_x-50;
			result_text.y = circle_pos_y-23;
			//result_text.text = "";
			result_text.setTextFormat(textfmt);
			result_text.autoSize = TextFieldAutoSize.CENTER;
			
			//
			addChild(color_circle);
			addChild(pickcolor_circle);
			addChild(rotate_circle);
			addChild(move_circle.instance);
			addChild(start_text);
			
			/// initial the timer
			timer = new Timer(25,0);
			timer.addEventListener(TimerEvent.TIMER,onRotateCircleTimer);
			show_result_timer = new Timer(2000,0);
			show_result_timer.addEventListener(TimerEvent.TIMER,onShowResultTimer);
			
			/// add listener
		    addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			///addEventListener(MouseEvent.MOUSE_DOWN,onMouseMove);
			addEventListener(MouseEvent.CLICK,onMouseClick);
		}
				
		
		/// 参数：弧度
		private function updateMoveCirclePos(radian:Number)
		{
			move_circle_pos_x = circle_pos_x+move_circle_R*Math.cos(radian); 
			move_circle_pos_y = circle_pos_y+move_circle_R*Math.sin(radian);
			move_circle.instance.x = move_circle_pos_x-11.8;  /// offset to the left top corner of the image
			move_circle.instance.y = move_circle_pos_y-11.8;								
		}
		
		private function setRotateCircleColor()
		{
			var radian:Number = 2*Math.PI*Math.random();
			var temp_pos_x:Number = circle_pos_x+move_circle_R*Math.cos(radian); 
			var temp_pos_y:Number = circle_pos_y+move_circle_R*Math.sin(radian);
			current_rotate_color = color_circle_bmpdate.getPixel(temp_pos_x,temp_pos_y);			
		}
		
		private function checkColorMatch()
		{
			var pixelValue1:uint = uint(chosen_color);
			var red1:uint = pixelValue1 >> 16 & 0xFF;
			var green1:uint = pixelValue1 >> 8 & 0xFF;
			var blue1:uint = pixelValue1 & 0xFF;
			
			var pixelValue2:uint = uint(current_rotate_color);
			var red2:uint = pixelValue2 >> 16 & 0xFF;
			var green2:uint = pixelValue2 >> 8 & 0xFF;
			var blue2:uint = pixelValue2 & 0xFF;
			
			/// do test
			var d1:int = Math.abs(red1-red2);
			var d2:int = Math.abs(green1-green2);
			var d3:int = Math.abs(blue1-blue2);
					
			var textfmt:TextFormat = new TextFormat();
			textfmt.color = 0x000000;
			textfmt.size = 30;
			
			/// set the result text
			if(d1+d2+d3<8)
				result_text.text = "Perfect";
			else
			if(d1+d2+d3<80)
				result_text.text = "Good";
			else
			    result_text.text = "Poor";
			
			result_text.setTextFormat(textfmt);
			addChild(result_text);
		}
				
		/// 
		private function updatePickColorCircleColor()
		{
			current_pick_color = color_circle_bmpdate.getPixel(move_circle_pos_x,move_circle_pos_y);
			DrawSector(pickcolor_circle,circle_pos_x,circle_pos_y,90,360,270,current_pick_color);
		}
		
		private function onMouseClick(Event:MouseEvent):void
		{						
			if(game_playing == false)
			{
				game_playing = true;
				if(contains(start_text))
				   removeChild(start_text);
				setRotateCircleColor();
				timer.start();
				return;
			}
			
			if(game_playing)
			{
				removeEventListener(MouseEvent.CLICK,onMouseClick);
				chosen_color =  color_circle_bmpdate.getPixel(move_circle_pos_x,move_circle_pos_y);
				checkColorMatch();
				/// end the game
				rotate_circle.graphics.clear();	
				game_playing = false;
				checkColorMatch();
				addChild(result_text);
				current_angle = 0;
				
				show_result_timer.start();
				timer.stop();				
			}
		}
			
		private function onMouseMove(Event:MouseEvent):void
		{			
			var radian:Number = Math.atan((mouseY-circle_pos_y)/(mouseX-circle_pos_x));
			
			if(mouseX<circle_pos_x)
				radian += Math.PI;
			
			/// update the move_circle position
			updateMoveCirclePos(radian);	
			/// update the color of pickcolor_circle 
			pickcolor_circle.graphics.clear();
			updatePickColorCircleColor();					
		}
		
		private function onShowResultTimer(Event:TimerEvent):void
		{
			current_angle = 360;
			removeChild(result_text);
			addChild(start_text);
			///game_waiting = false;
			addEventListener(MouseEvent.CLICK,onMouseClick);
			show_result_timer.stop();
		}
		
		private function onRotateCircleTimer(Event:TimerEvent):void
		{
			/// the animation is about 10 seconds
			rotate_circle.graphics.clear();	
			DrawSector(rotate_circle,circle_pos_x,circle_pos_y,75,current_angle,270,current_rotate_color);
			current_angle -= 0.9;
			if(current_angle < 0)
			{
				rotate_circle.graphics.clear();	
				game_playing = false;
				checkColorMatch();
				addChild(result_text);
				removeEventListener(MouseEvent.CLICK,onMouseClick);
				current_angle = 0;
				show_result_timer.start();
				timer.stop();			
			}
		}
		
		
		function drawColorRing(sprite:Sprite, x:Number, y:Number)
		{
			var colors1 : Array = [0x0AF1F7,0x0AEF88,0x0DEB46,0x0DEE14,0x34EF0C,0x59F00D,0x83F009,0xABEE0B,0xD3ED0E,0xEFDF0D,0xF4B108,0xF26E09,0xFB0005];
			var colors2 : Array = [0x0AF1F7,0x0C99F0,0x0D4FEE,0x0814F4,0x2804EC,0x530AF1,0x7E0AEF,0xAA0AF2,0xD509F4,0xF307E7,0xF009AD,0xF70870,0xFB0005];
			var alphas : Array = [1,1,1,1,1,1,1,1,1,1,1,1,1];
			var ratios : Array = [0,20,40,60,80,100,120,140,160,180,200,220,240];
			var matrix : Matrix = new Matrix();
			//matrix.createGradientBox(400, 400, 0, 10, 0);
			matrix.createGradientBox(400, 400, 0, 14, 0);
			sprite.graphics.beginGradientFill(GradientType.LINEAR, colors1, alphas, ratios, matrix);
			createTopHalfCircle(sprite,x,y,200);
			sprite.graphics.beginGradientFill(GradientType.LINEAR, colors2, alphas, ratios, matrix);
			createBottomHalfCircle(sprite,x,y,200);
			sprite.graphics.beginFill(0xFFFFFF);
			createTopHalfCircle(sprite,x,y,175);
			createBottomHalfCircle(sprite,x,y,175);
		}
		
		// original circle function by senocular (www.senocular.com) from here http://www.actionscript.org/forums/showthread.php3?s=&threadid=30328
		function createTopHalfCircle(sprite:Sprite, x:Number,y:Number,r:Number):void {
			
			var c1:Number=r * (Math.SQRT2 - 1);
			var c2:Number=r * Math.SQRT2 / 2;
			// 上半圆
			sprite.graphics.moveTo(x-r,y);
			sprite.graphics.curveTo(x-r,y-c1,x-c2,y-c2);
			sprite.graphics.curveTo(x-c1,y-r,x,y-r);
			sprite.graphics.curveTo(x+c1,y-r,x+c2,y-c2);
			sprite.graphics.curveTo(x+r,y-c1,x+r,y);
		};
		
		function createBottomHalfCircle(sprite:Sprite, x:Number,y:Number,r:Number):void {
			
			var c1:Number=r * (Math.SQRT2 - 1);
			var c2:Number=r * Math.SQRT2 / 2;			
			/// 下半圆
			sprite.graphics.moveTo(x+r,y);
			sprite.graphics.curveTo(x+r,y+c1,x+c2,y+c2);
			sprite.graphics.curveTo(x+c1,y+r,x,y+r);
			sprite.graphics.curveTo(x-c1,y+r,x-c2,y+c2);
			sprite.graphics.curveTo(x-r,y+c1,x-r,y);
		};
		
		
		/// 画扇形函数
		function DrawSector(mc:Sprite,x:Number,y:Number,r:Number,angle:Number,startFrom:Number,color:Number=0x000000):void {
			mc.graphics.beginFill(color,50);
			//remove this line to unfill the sector
			/* the border of the secetor with color 0xff0000 (red) , you could replace it with any color 
			* you want like 0x00ff00(green) or 0x0000ff (blue).
			*/
			mc.graphics.lineStyle(0,color);
			mc.graphics.moveTo(x,y);
			angle=(Math.abs(angle)>360)?360:angle;
			var n:Number=Math.ceil(Math.abs(angle)/45);
			var angleA:Number=angle/n;
			angleA=angleA*Math.PI/180;
			startFrom=startFrom*Math.PI/180;
			mc.graphics.lineTo(x+r*Math.cos(startFrom),y+r*Math.sin(startFrom));
			for (var i=1; i<=n; i++) {
				startFrom+=angleA;
				var angleMid=startFrom-angleA/2;
				var bx=x+r/Math.cos(angleA/2)*Math.cos(angleMid);
				var by=y+r/Math.cos(angleA/2)*Math.sin(angleMid);
				var cx=x+r*Math.cos(startFrom);
				var cy=y+r*Math.sin(startFrom);
				mc.graphics.curveTo(bx,by,cx,cy);
			}
			if (angle!=360) {
				mc.graphics.lineTo(x,y);
			}
			mc.graphics.endFill();// if you want a sector without filling color , please remove this line.
		}
		
		
		
	}
}