package main
{
    import flash.display.MovieClip;
    import flash.events.Event;

    dynamic public class AsteroidFall extends MovieClip
    {
        public var velocity:Vector_h; // вектор движения
        public var rot:Number; // направление вращения
        var earth_obj:BasicObject; // ссылка на планету
        var this_obj:BasicObject;

        // ссылка на астероид и на планету
        public function init(obj:BasicObject, earth:BasicObject)
        {
            // копируем вектор движения
            velocity = new Vector_h();
            velocity.copyVector(obj.velocity);
            // копируем изображение астероида
            this.bg.gotoAndStop(obj.bg.currentFrame);
            this.bg.rotation = obj.bg.rotation;
            // позиция та же
            x = obj.x;
            y = obj.y;
            // вращение в ту же сторону
            rot = obj.rot;
            // радиус такой же
           // radius=obj.radius;
            // запоминаем ссылку на объект планеты
            earth_obj = earth;
            this_obj = obj;
            // двигаемся самостоятельно
            addEventListener(Event.ENTER_FRAME, move);
            // следующими кадрами у нас нарисован взрыв, а пока отображаем астероид
            stop();
        }

        // Переместиться
        public function move(event:Event):void
        {
            // при падении на землю, вектор движения должен плавно меняться к центру планеты
            var v:Vector_h = new Vector_h(earth_obj.x-x, earth_obj.y-y);
            v.mulScalar(1/earth_obj.radius);
            // а скорость движения должна уменьшаться
            var len = velocity.magnitude()*0.95;
            velocity.addVector(v);
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
                earth_obj.hp -= this_obj.radius; // уменьшим HP земли, дамаг пропорционален нашему размеру
                dispatchEvent(new Event("CHANGE_EARTH_HP"));
                removeEventListener(Event.ENTER_FRAME, move);
                gotoAndPlay(2);
                scaleX=scaleY=1;
            }
        }

        // удалить свой мувик
        function remove()
        {
            stop();
            if (parent){ parent.removeChild(this) }
        }
    }
}
