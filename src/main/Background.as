package main
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.events.*;
	
	/**
	 * ...
	 * @author Ruslan
	 */
	public class Background extends MovieClip
	{
		
		public function Background()
		{
			// Перехватываем нажатие кнопки мыши по нашему мувику
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			// Отпускание мышки
			addEventListener(Event.MOUSE_LEAVE, handleMouseUp);


		}
		
		// Нажатие кнопки мыши по нашему мувику
		function handleMouseDown(event:Event):void
		{
			var dx:Number = width-stage.stageWidth;
			var dy:Number = height-stage.stageHeight;
			var dragRect:Rectangle = new Rectangle(-dx,-dy, dx,dy);
			(this.parent as MovieClip).startDrag(false, dragRect);
		}
		// Отпустили кнопку мыши
		function handleMouseUp(event:Event):void
		{
			(this.parent as MovieClip).stopDrag();
		}
	}

}