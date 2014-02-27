package com 
{
	import flash.utils.Timer;
	import flash.text.*;
	import flash.display.Sprite;
	import flashx.textLayout.formats.TextAlign;
	import flash.events.TimerEvent;
	/**
	 * ...
	 * @date 2012
	 * @author myqianlan
	 * @email linquantan@gmail.com
	 * 用于提示等信息
	 * 定义一次可以多次调用
	 */

	public class Tips extends Sprite
	{
		private var time:Timer;
		private var label:TextField;
		private var n:int = 0;
		public function Tips()
		{
			time = new Timer(400);
			label = new TextField();
			label.text = " ";
			label.textColor=0xFF0000;
			label.border=false;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.selectable = false;
			label.multiline = false;
			label.wordWrap = false;
		}
		public function out(txt:String,lx:Number,ly:Number,color:uint)
		{
			addChild(label);
			label.text = txt;
			this.x = lx;
			this.y = ly;
			this.height=200;
			
			time.start();
			time.addEventListener(TimerEvent.TIMER,timehander);
		}
		private function timehander(e:TimerEvent)
		{
			n++;
			//显示完后尽量释放内存
			if (n==10)
			{
				n = 0;
				label.text = "";
				removeChild(label);
				time.removeEventListener(TimerEvent.TIMER,out);
				time.stop();
			}
		}
	}

}