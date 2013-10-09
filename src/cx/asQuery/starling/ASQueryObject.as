package cx.asQuery.starling
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * ASQuery主类
	 * @author 翼翔天外
	 */
	public final class ASQueryObject
	{
		/**
		 * 所有元素的数组 
		 */
		private var _list:Array;		
		/**
		 * 根容器的记录
		 */
		private var _root:DisplayObjectContainer;
		/**
		 * 选择器的记录 
		 */
		private var _selector:*;
		
		/**
		 * 
		 * @param root		主容器
		 * @param selector	选择器
		 * @param onlyChild	是否只遍历主容器的第一层子对象（否则遍历所有层级的子集）
		 * 
		 */
		public function ASQueryObject(root:DisplayObjectContainer,selector:*,onlyChild:Boolean = false)
		{
			_root = root;
			_selector = selector;
			_list = [];
			if(selector is ASQueryObject)//如果传入ASQuery元素直接赋值
			{
				this._root = ASQueryObject(selector)._root;
				this._list = ASQueryObject(selector)._list;
			}
			if(selector is String)//名字
			{
				//名字可以用空格拆分
				var nameList:Array = String(selector).split(" ");
				var nameIndex:int = 0;
				var nameNum:int = nameList.length;
				var childList:Array;
				for(; nameIndex < nameNum ; nameIndex++)
				{
					childList = [];
					if(onlyChild)
					{
						ASQueryHelper.findChildByName(nameList[nameIndex],_root,childList);
					}
					else
					{
						ASQueryHelper.findAllChildByName(nameList[nameIndex],_root,childList);
					}
					_list = _list.concat(childList);
				}
			}
			else
			if(selector is Class)//类
			{
				if(onlyChild)
				{
					ASQueryHelper.findChildByClass(selector,_root,_list);
				}
				else
				{
					ASQueryHelper.findAllChildByClass(selector,_root,_list);
				}
			}
			else
			if(selector is DisplayObject)//实例
			{
				_list.push(selector);
			}
			else
			if(selector is Array)//数组
			{
				_list = (selector as Array).concat();
			}
		}
		
		//------------- 通用函数   --------------
		/**
		 * 初始化方法
		 * 确保在舞台上或添加到舞台时触发一次
		 * 一般在显示对象构造函数中调用:$(this).ready(init)
		 * @param fun 初始化回调函数
		 * 此方法无返回
		 * 
		 */
		public function ready(fun:Function):void
		{
			all(function(item:DisplayObject):void
			{
				if(item.stage != null)
				{
					fun();
				}
				else
				{
					$(item).bind(Event.ADDED_TO_STAGE,function(e:Event):void
					{
						$(item).unbind(Event.ADDED_TO_STAGE,arguments.callee);
						fun.call(item);
					});
				}
			});
		}
		
		/**
		 * 设置属性 
		 * @param name	属性名，如果有多个用{"x":10,"y":20}
		 * @param value	单属性要设置的值(支持"+=10","-=10","*=10","/=10"几个运算符操作)
		 * @return 
		 * 
		 */
		public function attr(name:*,value:*=null):ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				if(name is String)
				{
					ASQueryHelper.setAttr(item,String(name),value);
				}
				else
				{
					for(var index:String in name)
					{
						ASQueryHelper.setAttr(item,index,name[index]);
					}
				}
			});
			return this;
		}
		
		/**
		 * 获取属性
		 * @param name
		 * @return 
		 * 
		 */
		public function getAttr(name:String):*
		{
			return get()[name];
		}
		
		/**
		 * 调用函数 
		 * @param name 	   函数名
		 * @param params 参数数组
		 * @return 
		 * 
		 */
		public function fun(name:String,params:Array=null):ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				if(name is String)
				{
					item[name].apply(null,params);
				}
			});
			return this;
		}
		
		/**
		 * 对所有元素执行操作
		 * @param fun
		 * @return 
		 * 
		 */
		public function all(fun:Function):ASQueryObject
		{
			var num:int = _list.length;
			for(var i:int = 0 ; i < num ; i++)
			{
				fun.call(null,_list[i]);
			}
			return this;
		}
		
		/**
		 * 通过新的选择器查找内部元素
		 * @param selector	选择器
		 * @param onlyChild	是否只遍历第一层子对象（否则遍历所有层级的子集）
		 * @return 
		 * 
		 */
		public function find(selector:*,onlyChild:Boolean = false):ASQueryObject
		{
			var newQuery:ASQueryObject = new ASQueryObject(_root,null);
			newQuery._selector = selector;
			all(function(item:DisplayObject):void
			{
				if(item is DisplayObjectContainer)
				{
					newQuery._list = newQuery._list.concat($(selector,DisplayObjectContainer(item),onlyChild)._list);
				}
			});
			return newQuery;
		}
		
		/**
		 * 绑定事件监听 
		 * @param type		事件类型
		 * @param handler	监听函数
		 * @return 
		 * 
		 */
		public function bind(type:String,handler:Function):ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				item.addEventListener(type,handler);
			});
			return this;
		}
		
		/**
		 * 解除事件监听
		 * 释放时可以不用显示调用此语句，因为Starling的dispose方法会清除所有子对象的监听。
		 * @param type		类型，如果不传，删除所有事件监听
		 * @param handler	函数，如果不传，删除所有本类型监听函数
		 * @return 
		 * 
		 */
		public function unbind(type:String = null,handler:Function = null):ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				if(handler == null)
				{
					item.removeEventListeners(type);
				}
				else
				{
					item.removeEventListener(type,handler);
				}
			});
			return this;
		}
		

		//bindOnce暂未实现，现阶段问题：如果实现，不能简单的包装，需要用户可以移除的它，
		//那么势必要和ASQuery原则的框架一样做一个监听的map映射
		//这样就会破坏当前只是转发starling的监听的优势，导致被监听会被框架引用，容易引发释放问题
		//建议暂时用bind之后再unbind来实现只有一次的监听
//		/**
//		 * 绑定只执行一次的事件监听 
//		 * @param type
//		 * @param handler
//		 * @return 
//		 * 
//		 */
//		public function bindOnce(type:String,handler:Function):ASQueryObject
//		{
//			return this;
//		}
		
		/**
		 * 触发事件 
		 * @param event		要触发的事件
		 * 
		 */
		public function trigger(event:Event):ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				item.dispatchEvent(event);
			});
			return this;
		}
		
		/**
		 * 获取内部元素
		 * @param index	匹配的第几个
		 * @return 
		 * 
		 */
		public function get(index:int = 0):DisplayObject
		{
			if(index < _list.length)
			{
				return _list[index];
			}
			return null;
		}
		
		/**
		 * 获得内部元素个数
		 * 如果为0，表示没有获取到元素
		 * @return 
		 * 
		 */
		public function length():int
		{
			return _list.length;
		}
		
		/**
		 * 获取内部容器 
		 * @param index 匹配的第几个
		 * @return 
		 * 
		 */
		public function getContainer(index:int = 0):DisplayObjectContainer
		{
			var num:int = _list.length;
			for(var i:int = 0 ; i < num ; i++)
			{
				if(_list[i] is DisplayObjectContainer)
				{
					return _list[i] as DisplayObjectContainer;
				}
			}
			return null;
		}
		
		
		//------------- 辅助函数  ---------------		
		/**
		 * 点击事件 （兼容按钮和普通显示对象）
		 * @param handler
		 * @return 
		 * 
		 */
		public function click(handler:Function):ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				if(item is Button)
				{
					$(item).bind(Event.TRIGGERED,handler);
				}
				else
				{
					//记录点击开始位置，用于判定是否是点击非移动
					var clickPoint:Point;
					$(item).bind(TouchEvent.TOUCH,function(event:TouchEvent):void
					{
						var touch:Touch = event.getTouch(item);
						if(touch)
						{
							switch(touch.phase)
							{
								case TouchPhase.BEGAN:
									clickPoint = new Point(touch.globalX,touch.globalY);
									break;
								case TouchPhase.ENDED:
									var buttonRect:Rectangle = item.getBounds(item.stage);
									var nowPoint:Point = new Point(touch.globalX,touch.globalY);
									//移动距离不大，并且释放时还在按钮范围内算点击
									if(nowPoint.subtract(clickPoint).length < 30 && buttonRect.containsPoint(nowPoint))
									{
										handler(event);
									}
									break;
							}
						}
					});
				}
			});
			return this;
		}
		
		/**
		 * 绑定touch事件 
		 * @param handler
		 * @return 
		 * 
		 */
		public function touch(handler:Function):ASQueryObject
		{
			return bind(TouchEvent.TOUCH,handler);
		}
		
		/**
		 * 绑定Touch Begin事件 
		 * @param handler
		 * @return 
		 * 
		 */
		public function touchBegin(handler:Function):ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				$(item).bind(TouchEvent.TOUCH,function(event:TouchEvent):void
				{
					var touch:Touch = event.getTouch(DisplayObject(event.currentTarget));
					if(touch && touch.phase == TouchPhase.BEGAN)
					{
						handler(event);
					}
				});
			});
			return this;
		}
		
		/**
		 * 绑定Touch End事件 
		 * @param handler
		 * @return 
		 * 
		 */
		public function touchEnd(handler:Function):ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				$(item).bind(TouchEvent.TOUCH,function(event:TouchEvent):void
				{
					var touch:Touch = event.getTouch(DisplayObject(event.currentTarget));
					if(touch && touch.phase == TouchPhase.ENDED)
					{
						handler(event);
					}
				});
			});
			return this;
		}
		
		/**
		 * 绑定Touch Hover事件 
		 * @param handler
		 * @return 
		 * 
		 */
		public function touchHover(handler:Function):ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				$(item).bind(TouchEvent.TOUCH,function(event:TouchEvent):void
				{
					var touch:Touch = event.getTouch(DisplayObject(event.currentTarget));
					if(touch && touch.phase == TouchPhase.HOVER)
					{
						handler(event);
					}
				});
			});
			return this;
		}
		
		/**
		 * 绑定Touch Move事件 
		 * @param handler
		 * @return 
		 * 
		 */
		public function touchMove(handler:Function):ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				$(item).bind(TouchEvent.TOUCH,function(event:TouchEvent):void
				{
					var touch:Touch = event.getTouch(DisplayObject(event.currentTarget));
					if(touch && touch.phase == TouchPhase.MOVED)
					{
						handler(event);
					}
				});
			});
			return this;
		}
		
		/**
		 * 切换Boolean类型的属性状态 
		 * @param name	要切换的属性名，如果不传默认visible属性
		 * @return 
		 * 
		 */
		public function toggle(name:String = null):ASQueryObject
		{
			if(name == null) name = "visible";
			all(function(item:DisplayObject):void
			{
				item[name] = !item[name];
			});
			return this;
		}
		
		/**
		 * 添加子元素
		 * @param child
		 * @return 
		 * 
		 */
		public function append(child:*):ASQueryObject
		{
			var container:DisplayObjectContainer = getContainer();
			if(container == null) return this;
			(new ASQueryObject(_root,child)).all(function(item:DisplayObject):void
			{
				container.addChild(child);
			});
			return this;
		}
		
		/**
		 * 添加到父元素
		 * @param parent
		 * @return 
		 * 
		 */
		public function appendTo(parent:*):ASQueryObject
		{
			var container:DisplayObjectContainer = (new ASQueryObject(_root,parent)).getContainer();
			if(container == null) return this;
			all(function(item:DisplayObject):void
			{				
				container.addChild(item);
			});
			return this;
		}
		
		/**
		 * 移除自己 
		 * @return 
		 * 
		 */
		public function remove():ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				item.parent.removeChild(item);
			});
			return this;
		}
		
		/**
		 * 移除所有子对象 ，但不释放他们的资源占用 
		 * @return 
		 * 
		 */
		public function empty():ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				var container:DisplayObjectContainer = item as DisplayObjectContainer;
				if(container != null)
				{
					while(container.numChildren)
					{
						container.removeChildAt(0);
					}
				}
			});
			return this;
		}
		
		/**
		 * 清理所有资源，并释放
		 * 注意：贴图和bitmapData不会自动释放，如果释放操作写在显示对象的dispose方法里面则会调用
		 * 此方法无返回
		 * 
		 */
		public function dispose():void
		{
			all(function(item:DisplayObject):void
			{
				item.dispose();
				//如果有父容器，从父容器移除自己
				if(item.parent != null)
				{
					item.parent.removeChild(item);
				}
			});
			//置空
			_list = null;
			_root = null;
			_selector = null;
		}
		
		/**
		 * 设置深度到顶层
		 * 
		 */
		public function setIndexTop():ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				item.parent.setChildIndex(item,item.parent.numChildren-1);
			});
			return this;
		}
		
		/**
		 * 设置深度到底层
		 * @param index
		 * 
		 */
		public function setIndexBottom():ASQueryObject
		{
			all(function(item:DisplayObject):void
			{
				item.parent.setChildIndex(item,0);
			});
			return this;
		}	
		
		/**
		 * 输出字符串 
		 * @return 
		 * 
		 */
		public function toString():String
		{
			var itemStr:String = "list:";
			var num:int = _list.length;
			for(var i:int = 0; i < num ; i++)
			{
				itemStr += _list[i] + ",";
			}
			itemStr = itemStr.substr(0,itemStr.length-1);
			return "[AsQueryObject]\r selector:" + _selector + "\r root:" + _root + "\r " + itemStr;
		}
	}
}