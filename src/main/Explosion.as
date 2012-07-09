package main
{
    import flash.display.MovieClip;
    import flash.events.Event;

    dynamic public class Explosion extends MovieClip
    {
        public var velocity:Vector_h; // вектор движения

        public function init(obj:BasicObject)
        {
            // ссылка на взорвавшийся объект
            velocity = new Vector_h();
            // вектор движения взрыва тот же, что и у астероида
            velocity.copyVector(obj.velocity);
            velocity.mulScalar(1/2); // только чуть медленней
            // позиция из центра астероида
            x = obj.x;
            y = obj.y;
            // случайно повернем мувик взрыва, чтобы внести разннобразие
            rotation = 360*(Math.random()-0.5);
            // изменим масштаб, чтобы взрыв соответствовал по размерам
            // взорвавшемуся объекту
            scaleX=scaleY=2*obj.radius/40;
            // двигаемся самостоятельно
            addEventListener(Event.ENTER_FRAME, move);
        }

        // Переместиться
        public function move(event:Event):void
        {
            x += velocity.x;
            y += velocity.y;
        }

        // Самоудалиться. Вызов этой функции прописан в последнем кадре взрыва
        public function remove():void
        {
            removeEventListener(Event.ENTER_FRAME, move);
            if (parent)
            {
                parent.removeChild(this);
            }
        }
    }
}
