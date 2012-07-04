package main
{
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.geom.Rectangle;

    public class Background extends MovieClip
    {
        public function Background()
        {
            // Перехватываем нажатие кнопки мыши по нашему мувику
            addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
            // Отпускание мышки
            stage.addEventListener(Event.MOUSE_LEAVE, handleMouseUp);
            addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
        }

        // Нажатие кнопки мыши по нашему мувику
        function handleMouseDown(event:Event):void
        {
            var dx2:Number = width-stage.stageWidth;
            var dy2:Number = height - stage.stageHeight;
            var dragRect:Rectangle = new Rectangle(64, -20, dx2, dy2);
            (this.parent as MovieClip).startDrag(false, dragRect);
        }
        // Отпустили кнопку мыши
        function handleMouseUp(event:Event):void
        {
            (this.parent as MovieClip).stopDrag();
        }
    }
}
