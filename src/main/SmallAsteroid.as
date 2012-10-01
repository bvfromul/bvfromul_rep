package main
{
    import flash.display.MovieClip;
    import flash.events.Event;

    dynamic public class SmallAsteroid extends MovieClip
    {
        private var asteroidSpallMinSpeed:Number = GameConst.asteroidSpallMinSpeed;
        private var asteroidSpallMaxSpeed:Number = GameConst.asteroidSpallMaxSpeed;
        public var velocity:Vector_h; // вектор движения
        public var rot:Number; // направление вращения
        public var cnt:Number; // счетчик до полного изчезновения осколка

        public function init(obj:BasicObject)
        {
            // ссылка на взорвавшийся объект
            //случайный вектор
            velocity = new Vector_h(100*(Math.random()-0.5),100*(Math.random()-0.5));
            // скорость
            var spd:Number = asteroidSpallMinSpeed + (asteroidSpallMaxSpeed-asteroidSpallMinSpeed)*Math.random();
            // приведем длину вектора к выбранной скорости
            velocity.mulScalar( spd / velocity.magnitude() );
            // складываем с вектором взрывающегося объекта
            // чтобы основная масса осколков летела в том же направлении,
            // что и астероид до этого
            velocity.addVector(obj.velocity);

            // позиция из центра астероида
            x = obj.x;
            y = obj.y;
            // зададим случайное направление вращения
            rot = 5*(Math.random()-0.5);

            // сделаем небольшой рандом в размере, чтобы осколки не были похожи друг на друга
            scaleX=scaleY=0.3+Math.random()*1.7;

            // зададим, через сколько "шагов" полностью исчезнуть
            cnt = 10+Math.floor(10*Math.random());

            // двигаемся самостоятельно
            addEventListener(Event.ENTER_FRAME, move);
        }

        // Переместиться
        public function move(event:Event):void
        {
            x += velocity.x;
            y += velocity.y;
            rotation += rot; // и немного повернуться
            if (cnt < 5)
            {
                // осталось жить очень мало, постепенно исчезаем
                alpha = cnt/5;
            }

            if (cnt-- <= 0)
            {
                // срок жизни вышел. самоудаляемся
                removeEventListener(Event.ENTER_FRAME, move);
                if (parent)
                {
                    parent.removeChild(this)
                }
            }
        }
    }
}
