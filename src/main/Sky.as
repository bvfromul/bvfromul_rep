package main
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import main.MovingObject;

    dynamic public class Sky extends MovieClip
    {
        var MIN_DROP:Number, MAX_DROP:Number; // пределы количества вбрасываемых астероидов
        var all_moving:Array; // здесь все движущиеся объекты
        var all_sectors:Object;      // сектора со ссылками на объекты в них

        public function Sky()
        {
            all_moving = new Array();
            all_sectors = new Object();
            // сколько астероидов вбрасывается
            // это не константы, т.к. со временем количество астероидов должно увеличиваться
            MIN_DROP=5; MAX_DROP=10;

            addEventListener(Event.ENTER_FRAME, Update);
            // тестовый вброс
            DropSeveralAsteroids();
        }

        public function DropSeveralAsteroids():void
        {
            var x1:Number, y1:Number; // точка вброса
            var x2:Number, y2:Number; // куда двигаться
            var cnt:Number;    // количество вбрасываемых встероидов
            var new_asteroid:MovingObject; // объект астероида
            var s:String;

            x1=0; y1=0; // пока так, для теста, из левого верхнего угла
            x2=this.earth.x; y2=this.earth.y; // двигаться к земле
            // выбираем рандомное количество
            cnt = MIN_DROP + Math.floor((MAX_DROP-MIN_DROP)*Math.random());
            while (cnt--)
            {
                new_asteroid = new MovingObject();     // создаем новый астероид
                addChild(new_asteroid);           // добавляем его на наш мувиклип
                all_moving.push(new_asteroid);    // запоминаем в массиве
                new_asteroid.drop(x1, y1, x2, y2);  // бросаем

                // Просим пересчитать в какие сектора попал объект
                new_asteroid.CalcSectors();
                // добавим в эти сектора ссылку на объект
                for (s in new_asteroid.sectors)
                {
                    if (!all_sectors[s]) // такого сектора еще не было, создадим
                        all_sectors[s] = new Object();
                    all_sectors[s][new_asteroid.name] = new_asteroid;
                }
            }
        }

        public function Update(e : Event):void
        {
            var s:String, obj2:MovingObject;
            // Проходим по всему массиву созданных объектов
            // и заставляем каждого сдвинуться в своем направлении
            for each (var obj:MovingObject in all_moving)
            {
                // перед тем, как сдвинуться удалим запись об этом объекте из секторов
                for (s in obj.sectors)
                    delete all_sectors[s][obj.name];

                // смещаемся
               obj.move();
               // Просим пересчитать в какие сектора попал объект
               obj.CalcSectors();
               // Проверяем столкновения со всеми объектами, которые есть в новых секторах
               for (s in obj.sectors)
               {
                    if (all_sectors[s])
                    {  // такой сектор есть
                        for each (obj2 in all_sectors[s])
                        { // проверяем на столкновение
                            if (obj.CheckCollision(obj2)) // столкнулись
                                   // делаем отскок
                                   resolve(obj, obj2);
                        }
                    }
                    else  // нет такого сектора
                     all_sectors[s] = new Object(); // теперь будет

                    // регистрируемся в этом секторе
                    all_sectors[s][obj.name]=obj;
                }
            }
        }

        function resolve(ball1:MovingObject, ball2:MovingObject):void
        {
            var b1Velocity:Vector_h = ball1.velocity;
            var b2Velocity:Vector_h = ball2.velocity;
            var b1Mass:Number     = ball1.getMassa();
            var b2Mass:Number     = ball2.getMassa();

            // Отодвинем легкий шарик назад, чтобы не пересекались
            if (b1Mass<b2Mass) PullBalls(ball1, ball2);
            else PullBalls(ball2, ball1);

            var lineOfSight:Vector_h = new Vector_h(ball1.x-ball2.x, ball1.y-ball2.y);
            var v1Prime:Vector_h = b1Velocity.vectorProjectionOnto(lineOfSight);
            var v2Prime:Vector_h = b2Velocity.vectorProjectionOnto(lineOfSight);

            var v1Prime2:Vector_h = new Vector_h();
            v1Prime2.copyVector(v2Prime);
            v1Prime2.mulScalar(2*b2Mass);
            v1Prime2.addVector(v1Prime.getMulScalar(b1Mass - b2Mass));
            v1Prime2.mulScalar(1.0/(b1Mass + b2Mass));

            var v2Prime2:Vector_h = new Vector_h();
            v2Prime2.copyVector(v1Prime);
            v2Prime2.mulScalar(2*b1Mass);
            v2Prime2.subVector(v2Prime.getMulScalar(b1Mass - b2Mass));
            v2Prime2.mulScalar(1.0/(b1Mass + b2Mass));

            v1Prime2.subVector(v1Prime);
            v2Prime2.subVector(v2Prime);

            b1Velocity.addVector(v1Prime2);
            b2Velocity.addVector(v2Prime2);
        }

        // Отодвигает шарик 1 от шарика 2, чтобы они не пересекались
        function PullBalls(ball1:MovingObject, ball2:MovingObject):void
        {
            var v:Vector_h = new Vector_h(ball1.x-ball2.x, ball1.y-ball2.y);
            var distance:Number = v.magnitude();
            var min_distance:Number = ball1.radius + ball2.radius;
            if (distance > min_distance) return; // не пересекаются
            v.mulScalar((0.1+min_distance-distance)/distance);
            ball1.x += v.x;
            ball1.y += v.y;
        }
    }
}
