package main
{
    import flash.display.MovieClip;

    dynamic public class MovingObject extends BasicObject
    {
        private var dropRadius:Number = GameConst.dropRadius;
        private var minSpeed:Number = GameConst.minSpeed;
        private var maxSpeed:Number = GameConst.maxSpeed;
        private var rot:Number;

        public function MovingObject()
        {
            var num:Number = Math.floor(Math.random() * (this.bg.totalFrames - 1)) + 1; // случайный кадр
            this.bg.gotoAndStop(num); // и переходим на него
            velocity = new Vector_h(); // создаем вектор
            // вычислим наш радиус, основываясь на размере картинки
            radius = Math.floor((this.bg.width + this.bg.height) / 4);
            // зададим случайное направление вращения
            rot = 2 * (Math.random() - 0.5);
            tkHP = mHP = 100;
        }

        // Вбросить объект рядом с указанной точкой x1:y1 и двигаться к x2:y2
        public function drop(x1:Number, y1:Number, x2:Number, y2:Number):void
        {
            // координата вброса
            x = x1 + (Math.random()-0.5)*dropRadius;
            y = y1 + (Math.random() - 0.5) * dropRadius;
            // направление
            velocity.setMembers(x2 - x, y2 - y);
            // скорость
            var spd:Number = minSpeed + (maxSpeed-minSpeed)*Math.random();
            // приведем длину вектора к выбранной скорости
            velocity.mulScalar( spd / velocity.magnitude() );
        }

        override public function move():void
        {
            x += velocity.x;
            y += velocity.y;
            this.bg.rotation += rot; // и немного повернуться
        }
    }
}
