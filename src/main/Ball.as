package main
{
    import flash.display.MovieClip;
    import flash.events.*;

    dynamic public class Ball extends MovieClip
    {
        var velocity:Vector_h;   // направление и скорость

        function Ball()
        {
           // зададим случайное движение
           velocity = new Vector_h(4*(Math.random()-0.5),4*(Math.random()-0.5));
           // Движение шарика
           addEventListener(Event.ENTER_FRAME, Update);
        }

        public function Update(e : Event):void
        {
           var new_x:Number = x+velocity.x;
           var new_y:Number = y+velocity.y;
           var r = radius;
           // отскоки от краев экрана
           if (new_x-r<0 || new_x+r>stage.width) velocity.x=-velocity.x;
           if (new_y-r<0 || new_y+r>stage.height) velocity.y=-velocity.y;

           move();
        }

        function get radius():Number
        {
           return width/2;
        }

        function getMassa():Number
        {
            var r:Number = radius;
            return (4/3*Math.PI*r*r*r)/100;       // масса шара
        }

        // Переместиться
        function move():void
        {
            x += velocity.x;
            y += velocity.y;
        }

        // Вычисляет расстояние до другого объекта в квадрате
        // Функция sqrt довольно медленная и быстрее оперировать расстоянием в квадрате
        public function distance2(obj2:Ball):Number
        {
            var dx:Number = x - obj2.x;
            var dy:Number = y - obj2.y;
            return dx*dx + dy*dy;
        }

        // Определяет, столкнулись два объекта или нет
        public function CheckCollision(obj2:Ball):Boolean
        {
            var d2:Number = distance2(obj2); // квадрат расстояния
            var dr:Number = radius + obj2.radius; // сумма радиусов - минимальное возможное расстояние
            // если расстояние между объектами меньше суммы их радиусов - столкновение
            return (d2 < dr*dr);
        }
    }
}
