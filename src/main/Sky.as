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
            coordinates = { };
            var zone:String;
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
            all_moving.push(this.earth);
            this.earth.calcSectors();
            // добавим в эти сектора ссылку на объект
            for (zone in this.earth.sectors)
            {
                if (!all_sectors[zone])
                {
                    // такого сектора еще не было, создадим
                    all_sectors[zone] = {};
                }
                all_sectors[zone][this.earth.name] = this.earth;
            }
        }

        private function getDragAreaSize()
        {
            coordinates.dx1 = stage.stageWidth-Math.round((width-127)/2);
            coordinates.dy1 = stage.stageHeight-Math.round((height-50)/2);
            coordinates.dx2 = Math.round((width-127)/2) - coordinates.dx1;
            coordinates.dy2 = Math.round((height-50) / 2) - coordinates.dy1;
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
            var zone:String, obj2:MovingObject, i:Number, fragment:SmallAsteroid, ex_mc:Explosion;
            // Проходим по всему массиву созданных объектов
            // и заставляем каждого сдвинуться в своем направлении
            for each (var obj:BasicObject in all_moving)
            {
                if (obj.hp>0)
                {
                    if (obj.x<(-width-400) || obj.x>(width+400) || obj.y<(-height-400) || obj.y>(height+400))
                    {
                        obj.hp = 0;
                    }

                    if (obj.velocity.x!=0 && obj.velocity.y!=0 && Math.abs(obj.velocity.x)<0.4 && Math.abs(obj.velocity.y)<0.4)
                    {
                        obj.velocity.mulScalar(1.5); // увеличиваем скорость
                    }

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

                                       if (obj2.name == 'earth')
                                       {
                                           trace('yes');
                                           obj.hp=0; // взрыв

                                            // на его место аттачим "падающий" астероид
                                            var f:AsteroidFall = new AsteroidFall();
                                            f.init(obj, this.earth);
                                            addChild(f);
                                        }
                                        else
                                        {
                                               // столкнулись
                                               // делаем отскок
                                               resolve(obj, obj2);
                                               obj.hp = obj.hp -15;
                                               obj2.hp = obj2.hp -15;
                                        }
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
                else
                {
                    // удаляем объект из списка живых
                    for (i = 0; i < all_moving.length; i++)
                    {
                        if (all_moving[i] == obj)
                        {
                            all_moving.splice(i,1);
                            break;
                        }
                    }

                    // аттачим несколько случайных осколков (5-15)
                    i = Math.max(5, Math.floor(Math.random()*15));
                    while (i--)
                    {
                        fragment = new SmallAsteroid(); // создаем новый осколок
                        fragment.init(obj);     // инициализация параметров
                        addChild(fragment);     // добавляем его на наш мувиклип
                    }

                    // аттачим мувик взрыва
                    ex_mc = new Explosion();
                    ex_mc.init(obj);
                    addChild(ex_mc);
                    // удаляем сам мувик астероида
                    removeChild(obj);
                    // учитываем влияние ударной волны взрыва на другие объекты
                    addExplosion(obj.x, obj.y, obj.getMassa());
                }
            }
        }

        function resolve(ball1:BasicObject, ball2:BasicObject):void
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
        function pullBalls(ball1:BasicObject, ball2:BasicObject):void
        {
            var v:Vector_h = new Vector_h(ball1.x-ball2.x, ball1.y-ball2.y);
            var distance:Number = v.magnitude();
            var min_distance:Number = ball1.radius + ball2.radius;
            if (distance > min_distance) return; // не пересекаются
            v.mulScalar((0.1+min_distance-distance)/distance);
            ball1.x += v.x;
            ball1.y += v.y;
        }

        // Оттолкнуть объекты находящиееся в радиусе взрыва
        // сила взрыва эквивалентна массе астероида
        function addExplosion(x:Number, y:Number, massa:Number)
        {
            var i:Number, j:Number; //названия сектора i_j
            var obj:BasicObject, s:String;
            var v:Vector_h;
            // т.к. один астероид может пересекать несколько секторов
            // для того, чтобы его несколько раз не просчитать
            // записываем уже просчитанные астероиды в "one"
            var one:Object = {};

            // считаем, что радиус влияния равен массе взорвавшегося объекта
            // пробегаемся по всем секторам, которые пересекает радиус влияния взрыва
            for (i = Math.floor((x - massa) / 100); i <= Math.floor((x + massa) / 100); i++)
            {
                for (j = Math.floor((y - massa) / 100); j <= Math.floor((y + massa) / 100); j++)
                {
                    // название сектора
                    s = i+"_"+j;
                    for each (obj in all_sectors[s])
                    {
                        // все объекты в секторе
                        if (! one[obj.name])
                        {
                            // этот объект еще не просчитывали
                            // создаем вектор до объекта
                            v = new Vector_h(obj.x - x, obj.y - y);
                            // Высчитываем длину вектора воздействия
                            // Уменьшение с расстоянием и нужно учесть разность масс
                            v.mulScalar(100/v.magnitude2() * (massa/obj.getMassa())/2);
                            // прибавляем вектор воздействия взрыва к вектору движения объекта
                            obj.velocity.addVector(v);
                            // запомним, что этот объект просчитали
                            one[obj.name]=true;
                        }
                    }
                }
            }
        }
    }
}
