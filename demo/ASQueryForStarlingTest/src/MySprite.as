package
{
	import starling.display.Quad;
	import starling.display.Sprite;

	/**
	 * 自定义显示对象 
	 * @author 翼翔天外
	 * @E-mail onechenxing@163.com
	 */
	public class MySprite extends Sprite
	{
		public function MySprite(name:String,color:uint):void
		{
			this.name = name;
			var quad:Quad = new Quad(50,50,color);
			addChild(quad);		
		}
	}
}