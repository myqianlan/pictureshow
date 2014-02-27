package
{

	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceEvent;
	import com.tonybeltramelli.airkinect.ActionManager;
	import com.tonybeltramelli.airkinect.userAction.dispatcher.ActionSignalDispatcher;
	import com.tonybeltramelli.airkinect.userAction.event.KinectGestureEvent;
	import com.tonybeltramelli.airkinect.userAction.gesture.LeftSwipe;
	import com.tonybeltramelli.airkinect.userAction.gesture.RightSwipe;
	import com.tonybeltramelli.airkinect.userAction.gesture.settings.part.GesturePart;
    import com.greensock.TweenLite;
	import com.Tips;
    import flash.events.IOErrorEvent;
    import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import fl.motion.MotionEvent;
	import fl.motion.easing.*;
	/**
	 * ...
	 * @date 2013
	 * @author myqianlan
	 * @email linquantan@gmail.com
	 */
	public class BasicGallery extends MovieClip
	{
		//默认的每张图片暂留时间
		private var timer:Timer = new Timer(3000);
		//默认的图片运动方向
		private var playDirection:String = "left";
		//初始化程序开始显示字幕的时间
		private var minuteTimer:Timer;

		private var obj:Object = new Object();
		private var imageHolder:MovieClip;
		private var imageAry:Array = [];
		private var imageVoAry:Array = [];
		private var allImageAry:Array = [];
		//各类初始化数据
		private var centerY:int =160 ;
		private var xAry:Array = [20,180,350,520,680];
		private var yAry:Array = [centerY + 100,centerY + 80,centerY + 50,centerY + 80,centerY + 100];
		private var sizeAry:Array = [0.4,0.75,1.3,0.75,0.4];
		private var alphaAry:Array = [0.3,0.7,1,0.7,0.3];
        //图片大小比例为5：4；
        private var imgWidth:Number = 400;
		private var imgHeight:Number = 320;
		private var canRotate:Boolean = true
		private var imageViewNum:int = 5;
		private var lastImageX:int = 780;
		//kinect相关变量申明
		private var _kinect : Kinect;
		private var _actionManager : ActionManager;
		private var _mainTitle:String="请在XML文件中输入主题";
		private var tips:Tips = new Tips();
		//构造函数
		public function BasicGallery() 
		{
			imageHolder = new MovieClip();
			imageHolder.x = 120;
			imageHolder.y = 90;
			imageHolder.alpha=0;
			this.addChild(imageHolder);
			rightBtn.visible=false;
			leftBtn.visible=false;
			addChild(tips);
			//判断KINECT是否已经连接
			if(Kinect.isSupported())
			{  
			    shortTimer();
				_build();
				tips.out("Kinect连接成功\n即将启动完全模式",400,200,0xffffff);
				//trace("Kinect is Connect");	
			}
			else {				
				 shortTimer();
				 tips.out("Kinect 设备连接失败\n即将启动无手势模式",400,200,0xffffff);
				//trace("Kinect is not Connect");
				}				
		}
		//定时函数
		public function shortTimer():void  
        {           
            minuteTimer=new Timer(4000,1);
            minuteTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete); 
            minuteTimer.start(); 
        } 
        public function onTimerComplete(event:TimerEvent):void 
        {  
		    rightBtn.visible=true;
			leftBtn.visible=true;
			loadXML("data.xml");
			TweenLite.to(imageHolder,3,{alpha:1});
        } 
	
		
		//KINECT相关
		private function _build() : void
		{	
			_kinect = Kinect.getDevice();
			var settings : KinectSettings = new KinectSettings();
			settings.skeletonEnabled = true;
			//settings.rgbEnabled = true;
			//settings.depthEnabled = true;
			_kinect.start(settings);
			_kinect.addEventListener(DeviceEvent.STARTED, _started);
            _actionManager = new ActionManager(60);
			//创建手势
			var leftHandLeftSwipe : LeftSwipe = new LeftSwipe(GesturePart.LEFT_HAND);
			leftHandLeftSwipe.dispatcher.addEventListener(KinectGestureEvent.LEFT_SWIPE, _leftSwipeWithLeftHandOccured);
			var rightHandRightSwipe : RightSwipe = new RightSwipe(GesturePart.RIGHT_HAND);
			rightHandRightSwipe.dispatcher.addEventListener(KinectGestureEvent.RIGHT_SWIPE, _RightSwipeWithRightHandOccured);
			//将手势加入到动作管理器
			_actionManager.add(leftHandLeftSwipe);
			_actionManager.add(rightHandRightSwipe);			
		}
		
		private function _started(event : DeviceEvent) : void 
		{
			_kinect.removeEventListener(DeviceEvent.STARTED, _started);
			addEventListener(Event.ENTER_FRAME, _enterFrame);
		}

		private function _enterFrame(event : Event) : void
		{			
			if(_kinect.users.length != 0)
			{
				//仅识别距离最近的那个人
				var uniqueUser : User = _getUniqueUser(_kinect.users);
				//加入到动作管理器中
				_actionManager.compute(uniqueUser);
			}			
		}
		
		private function _getUniqueUser(usersWithSkeleton : Vector.<User>) : User 
		{
			var i : int = 0;
			var userNumber : int = usersWithSkeleton.length;
			var user : User = usersWithSkeleton[i];

			if (userNumber > 1) {
				for (i = 0; i < userNumber; i++)
				{	
					if(usersWithSkeleton[i].position.world.z < user.position.world.z)
					{
						user = usersWithSkeleton[i];
					}
				}
			}	
			return user;
		}
		
		private function _leftSwipeWithLeftHandOccured(event : KinectGestureEvent) : void
		{
			//tips.out("Leftt hand left swipe detected",380,320,0xffffff);
			//trace("Right hand left swipe detected !");
			playDirection = "left";
			timer.reset();
			timer.start();
			move();
		}
		private function _RightSwipeWithRightHandOccured(event : KinectGestureEvent) : void
		{			
			//tips.out("Right hand right swipe detected",380,320,0xffffff);
			//trace("Right hand right swipe detected !");
			playDirection = "right";
			timer.reset();
			timer.start();
			move();
		}

		//解析XML文件
		private function loadXML(url:String):void
		{
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.load(new URLRequest(url));
			urlLoader.addEventListener(Event.COMPLETE, loadComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,urlLoaderError);

		}
		private function urlLoaderError(event:IOErrorEvent) 
		{
			_mainTitle="导入data.xml文件出错";
			showTitleTxt(_mainTitle);			
        }
		
		
		
		private function loadComplete(evt:Event):void
		{
			
			
			var xml:XML = new XML((evt.currentTarget as URLLoader).data);
			var imageXmlList:XMLList = parseXML(xml);
			var remainNum:int = imageViewNum-imageVoAry.length;
			var remainAry:Array = [];
			if(remainNum>0)
			{
				var index:int  = 0;
				for(var j:int = 0;j<remainNum;j++)
				{
					if(index>imageVoAry.length-1)
					{
						index = 0;
					}
					remainAry[j] = imageVoAry[index];
					index++;
				}
			}
			imageVoAry = imageVoAry.concat(remainAry);
			
			if (imageXmlList.length() > 0)
			{
				createGallery();
				timer.addEventListener(TimerEvent.TIMER, timerHd);
				timer.start();
			}
			
			showTitleTxt(_mainTitle);
			//添加鼠标和键盘的监听器
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keydownHandler);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyupHandler);
            stage.addEventListener(Event.ENTER_FRAME,enterHandler);			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			this.rightBtn.addEventListener(MouseEvent.CLICK, rightHandler);
			this.leftBtn.addEventListener(MouseEvent.CLICK, leftHandler);
			this.rightBtn.buttonMode = true;
			this.leftBtn.buttonMode = true;			
		}
		 
	
		private function parseXML(xml:XML):XMLList
		{
			
			_mainTitle=xml.@mainTitle;
			
			var imageXmlList:XMLList = xml.menu;
			for (var i:int = 0; i <imageXmlList.length(); i++)
			{
				var imageVo:ImageVo = new ImageVo();
				imageVo.imageUrl = imageXmlList[i]. @imageUrl;
				imageVo.imageName = imageXmlList[i]. @imageName;
				imageVoAry.push(imageVo);
			}
			return imageXmlList;
		}
		
        //创建图片墙
		private function createGallery():void
		{
			
			imageAry = [];
			allImageAry = [];
			var len:int = imageVoAry.length > imageViewNum ? imageViewNum:imageVoAry.length;
			for (var i:int = 0; i < imageVoAry.length; i++)
			{
				var img:Img = new Img();
				img.index = i;
				if (i < imageViewNum)
				{
					imageAry.push(img);
					
					img.x = xAry[i];
					img.y = yAry[i];
					img.scaleX = sizeAry[i];
					img.scaleY = sizeAry[i];
					img.alpha = alphaAry[i];
				}else {
					img.alpha = 0;	
					img.x = 200;
					img.y = 0;
				}
				allImageAry.push(img);
				imageHolder.addChild(img);
			
				var imgVo:Object = imageVoAry[i];
				loadImg(imgVo.imageUrl, img.thumbs);		
			}
			swapDepth();
			var middleIndex:int = int(imageViewNum / 2);
			showContentTxt(imageVoAry[imageAry[middleIndex].index]);
		}
		
		
		private function loadImg(url:String,cav:MovieClip):void
		{
			var loader:Loader = new Loader();
			loader.load(new URLRequest(url));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event){onCom(e,cav)});
			
		}
		
		
        private function onCom(e:Event,c:MovieClip):void 
        {
	         this.addChild(e.target.loader);
	         var pic:Loader = e.target.loader;
	         pic.content.width = imgWidth;
	         pic.content.height = imgHeight;
	         c.addChild(pic);
        }
		
		//图片的运动方式
		private function move():void
		{
			if (playDirection == "right")
			{
				var newIndex:int = imageAry[0].index - 1;
				if (newIndex < 0)
				{
					newIndex = imageVoAry.length - 1;
				}
				var newImg:Img = allImageAry[newIndex];
				newImg.x = -50;
				newImg.y = centerY;
				newImg.scaleX = 0.1;
				newImg.scaleY = 0.1;
				newImg.alpha = 0;
				imageAry.unshift(newImg);
				for (var i:int = 0; i < imageAry.length; i++)
				{
					var img = imageAry[i];
					if (i < imageAry.length - 1)
					{
						if(i==2)
						{
							TweenLite.to(img,1,{x:xAry[i],y:yAry[i],rotation:360,scaleX:sizeAry[i],scaleY:sizeAry[i],alpha:alphaAry[i]});
						}
						else
						{
						    TweenLite.to(img,1,{x:xAry[i],y:yAry[i],rotation:120*Math.random()-60,scaleX:sizeAry[i],scaleY:sizeAry[i],alpha:alphaAry[i]});
						}
					}
					else
					{//最后一个
						TweenLite.to(img,1,{x:lastImageX,y:centerY,scaleX:0.1,scaleY:0.1,alpha:0});
					}
				}

				imageAry.pop();
				swapDepth();
			}
			else if (playDirection == "left")
			{
				newIndex = imageAry[imageAry.length - 1].index + 1;
				if (newIndex > imageVoAry.length-1)
				{
					newIndex = 0;
				}
				newImg = allImageAry[newIndex];
				newImg.x = lastImageX;
				newImg.y = centerY;
				newImg.scaleX = 0.1;
				newImg.scaleY = 0.1;
				newImg.alpha = 0;
				imageAry.push(newImg);
				for (var j:int = 0; j < imageAry.length; j++)
				{
					img = imageAry[j];
					
					if (j >0)
					{
						if(j==3)
						{

						    TweenLite.to(img,1,{x:xAry[j - 1],y:yAry[j - 1],rotation:-360,scaleX:sizeAry[j - 1],scaleY:sizeAry[j - 1],alpha:alphaAry[j-1]});
						}
						else
						{
							TweenLite.to(img,1,{x:xAry[j - 1],y:yAry[j - 1],rotation:120*Math.random()-60,scaleX:sizeAry[j - 1],scaleY:sizeAry[j - 1],alpha:alphaAry[j-1]});
						}
					}					
					else
					{//最后一个
						TweenLite.to(img,1,{x:-50,y:centerY,scaleX:0.1,scaleY:0.1,alpha:0});
					}
				}

				imageAry.shift();
				swapDepth();
			}

			var middleIndex:int = int(imageViewNum / 2);
			showContentTxt(imageVoAry[imageAry[middleIndex].index]);
		}

		//交换深度
		private function swapDepth():void
		{
			imageHolder.addChild(imageAry[0]);
			if (imageAry[4])
			{
				imageHolder.addChild(imageAry[4]);
			}
			if (imageAry[1])
			{
				imageHolder.addChild(imageAry[1]);
			}
			if (imageAry[3])
			{
				imageHolder.addChild(imageAry[3]);
			}
			if (imageAry[2])
			{
				imageHolder.addChild(imageAry[2]);
			}
		}
		//键盘和鼠标相应函数
		public function isDown(key:int):Boolean {
                        return (obj[key] ? true : false);
                }

                private function keydownHandler(e:KeyboardEvent) {
                        obj[e.keyCode]=true;
                }

                private function keyupHandler(e:KeyboardEvent) {
                        obj[e.keyCode]=false;
                }
                public function enterHandler(e:Event):void {
                        if (isDown(37)) {
                            playDirection = "left";
			                timer.reset();
			                timer.start();
			                move();
                        }
                        if (isDown(39)) {
                            playDirection = "right";
			                timer.reset();
			                timer.start();
			                move();
                        }
                }
		
		private function rightHandler(evt:MouseEvent):void
		{
			playDirection = "right";
			timer.reset();
			timer.start();
			move();
		}

		private function leftHandler(evt:MouseEvent):void
		{			
			playDirection = "left";
			timer.reset();
			timer.start();
			move();
		}
		
		
		private function mouseWheelHandler(evt:MouseEvent):void
		{
			if (evt.delta > 1  && canRotate)
			{
				leftHandler(null);
				canRotate = false;
				setTimeout(canRotateHandler, 300);
			}else if(evt.delta<-1 && canRotate){
				rightHandler(null);
				canRotate = false;
				setTimeout(canRotateHandler, 300);
			}
		}
		
		private function canRotateHandler():void
		{
			canRotate = true;
		}
				
        //自动运动
		private function timerHd(evt:TimerEvent):void
		{
			move();
		}
		//文字显示
		private function showTitleTxt(_title:String):void
		{
				//trace("the mainTitle is ",_title)
			titleTxt.text = _title;
		}
		
		private function showContentTxt(obj:Object):void
		{
			showTxt.text = obj.imageName;
		}
    }
	
}
//存储XML加载进来的图片数据的数据结构
class ImageVo
{
	
	public var imageUrl:String;

	public var imageName:String;

}