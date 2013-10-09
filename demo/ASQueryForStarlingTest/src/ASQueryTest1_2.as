package
{
	import cx.asQuery.starling.*;
	
	import flash.geom.Point;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	/**
	 * ASQuery测试类  （不使用匿名函数,代码更清晰）
	 * Demo说明：构建两个显示对象，设定基本属性，并让他们可以拖动。
	 * @author 翼翔天外
	 * @E-mail onechenxing@163.com
	 */
	public class ASQueryTest1_2 extends Sprite
	{
		private var beginPoint:Point = new Point();
		
		public function ASQueryTest1_2()
		{
			//添初始化
			$(this).ready(init);
		}
		
		private function init():void
		{
			initDisplay();
			testQuery();
		}
		
		/**
		 * 构建测试显示对象
		 * 
		 */
		private function initDisplay():void
		{
			var a:Sprite = new MySprite("a",0x0000FF);
			addChild(a);
			var b:Sprite = new Sprite();
			b.name = "b";
			var quad:Quad = new Quad(25,25,0xFF8888);
			b.addChild(quad);
			addChild(b);
		}
		
		private function testQuery():void
		{
			//设置处理的主容器范围
			ASQueryConfig.stage = stage;	
			//通过名字设置多个属性
			$("a").attr({"x":100,"y":200}).attr("alpha",.5);
			$("b").attr("y",50);
			
			//绑定this下面所有Sprite的事件，实现拖动处理			
			$(this).find(Sprite)
				.touchBegin(onTouchBeginHandler)
			    .touchMove(onTouchMoveHandler);

			//输出程序中的所有Sprite看看
			trace($(Sprite));
		}
		
		/**
		 * 开始拖动 
		 * @param e
		 * 
		 */
		private function onTouchBeginHandler(e:TouchEvent):void
		{
			var item:DisplayObject = e.currentTarget as DisplayObject;
			var touch:Touch = e.getTouch(item);
			//记录开始点击的位置
			beginPoint.x = touch.globalX;
			beginPoint.y = touch.globalY;
			$(item).setIndexTop();			
		}
		
		/**
		 * 拖动过程
		 * @param e
		 * 
		 */
		private function onTouchMoveHandler(e:TouchEvent):void
		{
			var item:DisplayObject = e.currentTarget as DisplayObject;
			var touch:Touch = e.getTouch(item);
			//通过与上一次位置的差值来实现拖动
			item.x += touch.globalX - beginPoint.x;
			item.y += touch.globalY - beginPoint.y;
			beginPoint.x = touch.globalX;
			beginPoint.y = touch.globalY;			
		}		
	}
}