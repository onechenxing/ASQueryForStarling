package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	import starling.core.Starling;
	
	/**
	 * 主函数
	 * 用于启动Starling
	 * @author 翼翔天外
	 * @E-mail onechenxing@163.com
	 */
	public class Main extends Sprite
	{
		public function Main()
		{
			if(stage != null)
			{
				init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE,init);
			}
		}
		
		/**
		 * 添加到舞台，初始化starling 
		 * @param event
		 * 
		 */
		private function init(e:Event = null):void
		{
			if(hasEventListener(Event.ADDED_TO_STAGE))
			{
				removeEventListener(Event.ADDED_TO_STAGE,init);
			}
			
			//初始化Starling
			Starling.handleLostContext = true;
			var starling:Starling = new Starling(ASQueryTest,stage);
			starling.start();
			
			//显示上方文本
			var tf:TextField = new TextField();
			tf.text = "ASQuery for Starling Test";
			tf.width = 200;
			tf.mouseEnabled = false;
			addChild(tf);
		}
	}
}