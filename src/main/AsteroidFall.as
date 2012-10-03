package main
{
    import flash.display.MovieClip;
    import flash.events.Event;

    dynamic public class AsteroidFall extends MovieClip
    {
        public var velocity:Vector_h;            // вектор движения
        public var rot:Number;                   // направление вращения

        internal var earthObj:BasicObject;       // ссылка на планету
        internal var asteroidObj:BasicObject;    // ссылка на астероид

        // ссылка на астероид и на планету
        public function init(asteroid:BasicObject, earth:BasicObject)
        {
            // копируем вектор движения
            velocity = new Vector_h();
            velocity.copyVector(asteroid.velocity);
            // копируем изображение астероида
            this.bg.gotoAndStop(asteroid.bg.currentFrame);
            this.bg.rotation = asteroid.bg.rotation;
            // позиция та же
            x = asteroid.x;
            y = asteroid.y;
            // вращение в ту же сторону
            rot = asteroid.rot;
            // радиус такой же
           // radius=obj.radius;
            // запоминаем ссылку на объект планеты
            earthObj = earth;
            asteroidObj = asteroid;
            // двигаемся самостоятельно
            addEventListener(Event.ENTER_FRAME, move);
            // следующими кадрами у нас нарисован взрыв, а пока отображаем астероид
            stop();
        }

        // Переместиться
        public function move(event:Event):void
        {
            // при падении на землю, вектор движения должен плавно меняться к центру планеты
            var vector:Vector_h = new Vector_h(earthObj.x-x, earthObj.y-y);
            vector.mulScalar(1/earthObj.radius);
            // а скорость движения должна уменьшаться
            var len = velocity.magnitude()*0.95;
            velocity.addVector(vector);
            velocity.mulScalar(len/velocity.magnitude());
            // сдвигаемся
            x += velocity.x;
            y += velocity.y;
            this.bg.rotation += rot; // и немного повернуть изображение
            // уменьшаемся в размере
            scaleX-=0.01;
            scaleY-=0.01;
            if (scaleX < 0.1)
            {
                // совсем маленький, пора прекращать движение и рисовать взрыв
                earthObj.hp -= asteroidObj.radius; // уменьшим HP земли, дамаг пропорционален нашему размеру
                dispatchEvent(new Event("CHANGE_EARTH_HP"));
                removeEventListener(Event.ENTER_FRAME, move);
                gotoAndPlay(2);
                scaleX = scaleY = 1;

                if ((parent as Sky).panel)
                {
                    (parent as Sky).panel.PlaySnd('explode_to_earth', this);
                }
            }
        }

        // удалить свой мувик
        function remove()
        {
            stop();
            if (parent)
            {
                parent.removeChild(this);
            }
        }
    }
}
