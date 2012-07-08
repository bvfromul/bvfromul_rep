package main
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import main.MovingObject;
    import flash.geom.Rectangle;
    import flash.events.MouseEvent;

    dynamic public class Sky extends MovieClip
    {
        var MIN_DROP:Number, MAX_DROP:Number;   // пределы количества вбрасываемых астероидов
        var all_moving:Array;                   // здесь все движущиеся объекты
        var all_sectors:Object;                 // сектора со ссылками на объекты в них
        private var coordinates:Object;         // координаты для дрега фона

        public function Sky()
        {
            all_moving = [];
            all_sectors = { };
            coordinates = {};
            // сколько астероидов вбрасывается
            // это не константы, т.к. со временем количество астероидов должно увеличиваться
            MIN_DROP=5; MAX_DROP=10;

            //получаем координаты области для дрега фона
            getDragAreaSize();

            // Перехватываем нажатие кнопки мыши по нашему мувику
            addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
            // Отпускание мышки
            stage.addEventListener(Event.MOUSE_LEAVE, handleMouseUp);
            addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);

            addEventListener(Event.ENTER_FRAME, update);
            // тестовый вброс
            dropSeveralAsteroids();
        }

        private function getDragAreaSize()
        {
            coordinates.dx1 = stage.stageWidth-Math.round((width-50)/2);
            coordinates.dy1 = stage.stageHeight-Math.round(height/2);
            coordinates.dx2 = Math.round((width-50)/2) - coordinates.dx1;
            coordinates.dy2 = Math.round(height / 2) - coordinates.dy1;
        }

        // Нажатие кнопки мыши по нашему мувику
        function handleMouseDown(event:Event):void
        {
            var dragRect:Rectangle = new Rectangle(coordinates.dx1, coordinates.dy1, coordinates.dx2, coordinates.dy2);
            this.startDrag(false, dragRect);
        }

        // Отпустили кнопку мыши
        function handleMouseUp(event:Event):void
        {
            this.stopDrag();
        }

        public function dropSeveralAsteroids():void
        {
            var x1:Number, y1:Number; // точка вброса
            var x2:Number, y2:Number; // куда двигаться
            var cnt:Number;    // количество вбрасываемых встероидов
            var new_asteroid:MovingObject; // объект астероида
            var zone:String;

            x1=-500; y1=-310; // пока так, для теста, из левого верхнего угла
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
                new_asteroid.calcSectors();
                // добавим в эти сектора ссылку на объект
                for (zone in new_asteroid.sectors)
                {
                    if (!all_sectors[zone])
                    {
                        // такого сектора еще не было, создадим
                        all_sectors[zone] = {};
                    }
                    all_sectors[zone][new_asteroid.name] = new_asteroid;
                }
            }
        }

        public function update(event : Event):void
        {
            var zone:String, obj2:MovingObject;
            // Проходим по всему массиву созданных объектов
            // и заставляем каждого сдвинуться в своем направлении
            for each (var obj:MovingObject in all_moving)
            {
                // перед тем, как сдвинуться удалим запись об этом объекте из секторов
                for (zone in obj.sectors)
                {
                    delete all_sectors[zone][obj.name];
                }

                // смещаемся
               obj.move();
               // Просим пересчитать в какие сектора попал объект
               obj.calcSectors();
               // Проверяем столкновения со всеми объектами, которые есть в новых секторах
               for (zone in obj.sectors)
               {
                    if (all_sectors[zone])
                    {  // такой сектор есть
                        for each (obj2 in all_sectors[zone])
                        { // проверяем на столкновение
                            if (obj.checkCollision(obj2))
                            {
                                    // столкнулись
                                   // делаем отскок
                                   resolve(obj, obj2);
                                   obj.tkHP = obj.tkHP -10;
                                   obj2.tkHP = obj2.tkHP -10;
                            }
                        }
                    }
                    else
                    {
                        // нет такого сектора
                        all_sectors[zone] = {}; // теперь будет
                    }

                    // регистрируемся в этом секторе
                    all_sectors[zone][obj.name]=obj;
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
            if (b1Mass < b2Mass)
            {
                pullBalls(ball1, ball2);
            }
            else
            {
                pullBalls(ball2, ball1);
            }

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
        function pullBalls(ball1:MovingObject, ball2:MovingObject):void
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
