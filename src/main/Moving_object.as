package main
{
    import flash.display.MovieClip;
    import main.*;

    dynamic public class Moving_object extends Basic_object
    {
        public var Velocity:vector_h; // вектор движения
        private var rot:Number;

        const DROP_RADIUS:Number = 200;     // разброс при вбрасывании
        const MIN_SPEED:Number = 1;  // раброс начальной скорости
        const MAX_SPEED:Number = 10;

        public function Moving_object()
        {
            var num:Number;
            num = Math.floor(Math.random()*totalFrames)+1; // выбираем случайный кадр
            gotoAndStop(num); // и переходим на него
            Velocity = new vector_h(); // создаем вектор
            // вычислим наш радиус, основываясь на размере картинки
            radius = Math.floor((width + height) / 4);
            // зададим случайное направление вращения
            rot = 2*(Math.random()-0.5);
        }

        // Вбросить объект рядом с указанной точкой x1:y1 и двигаться к x2:y2
        public function drop(x1:Number, y1:Number, x2:Number, y2:Number):void
        {
            // координата вброса
            x = x1 + (Math.random()-0.5)*DROP_RADIUS;
            y = y1 + (Math.random() - 0.5) * DROP_RADIUS;
            // направление
            Velocity.setMembers(x2-x, y2-y);
            // скорость
            var spd:Number = MIN_SPEED + (MAX_SPEED-MIN_SPEED)*Math.random();
            // приведем длину вектора к выбранной скорости
            Velocity.mulScalar( spd / Velocity.magnitude() );
        }

        public function move():void
        {
            x += Velocity.x;
            y += Velocity.y;
            rotation += rot; // и немного повернуться
        }
    }
}
