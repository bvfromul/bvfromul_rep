package main
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import main.MovingObject;
    import flash.geom.Rectangle;
    import flash.events.MouseEvent;

    dynamic public class Sky extends MovieClip
    {
        const INC_DROP:Number = 0.5;    // скорость увеличения количества астероидов
        const FIRST_DROP:Number = 3;    // Сколько астероидов вбрасывается вначале

        var DROP_CNT:Number;    // примерное количество вбрасываемых астероидов
        var MIN_DROP:Number, MAX_DROP:Number;   // пределы количества вбрасываемых астероидов
        var all_moving:Array;                   // здесь все движущиеся объекты
        var all_sectors:Object;                 // сектора со ссылками на объекты в них
        var first_pause:Number; // неск. секунд в начале игры не бросаем астероиды

        public function Sky()
        {
            all_moving = [];
            all_sectors = { };
            var zone:String;
            // сколько астероидов вбрасывается
            // это не константы, т.к. со временем количество астероидов должно увеличиваться
            MIN_DROP=5; MAX_DROP=10;

            DROP_CNT = FIRST_DROP;
            first_pause = 21*7; // пауза в начале игры


            // Перехватываем нажатие кнопки мыши по нашему мувику
            addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
            // Отпускание мышки
            stage.addEventListener(Event.MOUSE_LEAVE, handleMouseUp);
            addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);

            addEventListener(Event.ENTER_FRAME, update);
            // тестовый вброс
            dropSeveralAsteroids();
            addObjectInSectors(this.earth);

            this.earth.tkHP = this.earth.mHP = 100;
            this.earth.type = 'earth';

            //добавляем панельку
            var panel:Panel;
            panel = new Panel(this);
            panel.x = 0;
            panel.y = 60;
            stage.addChild(panel);
        }

        // Нажатие кнопки мыши по нашему мувику
        function handleMouseDown(event:Event):void
        {
            var dx1:Number = stage.stageWidth-Math.round((this.sky.width) / 2);
            var dy1:Number = stage.stageHeight-Math.round(this.sky.height/2);
            var dx2:Number = Math.round((this.sky.width ) / 2) - dx1;
            var dy2:Number = Math.round(this.sky.height/2) - dy1;
            var dragRect:Rectangle = new Rectangle(dx1, dy1, dx2, dy2);

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

            x2=Math.floor(Math.random()*4); // с какой стороны влетают астероиды 0-слева,1-верх,2-справа,3-снизу
            y2=Math.random()*2000; // местоположение не стороне
            x1=(x2==0?-100:(x2==1?y2:(x2==2?2100:y2)));
            y1 = (x2 == 0?y2:(x2 == 1? -100:(x2 == 2?y2:2100)));
            //x1=-800; y1=-310; // пока так, для теста, из левого верхнего угла
            x2=this.earth.x; y2=this.earth.y; // двигаться к земле
            // выбираем рандомное количество
            cnt = Math.floor(DROP_CNT + (DROP_CNT / 3) * (Math.random() - 0.5)); // 30% рандом

            if (all_moving.length + cnt > 10)
            {
                // ограничим макимальное количество астероидов в игре
                cnt = 11-all_moving.length;
            }
            if (cnt <= 0)
            {
                // нечего добавлять
                return;
            }

            while (cnt--)
            {
                new_asteroid = new MovingObject();     // создаем новый астероид
                new_asteroid.type = "asteroid";
                addChild(new_asteroid);           // добавляем его на наш мувиклип
                new_asteroid.drop(x1,y1,
                    x2+(this.earth.radius*(Math.random()-0.5)*0.8),
                    y2+(this.earth.radius*(Math.random()-0.5)*0.8)
                );

                addObjectInSectors(new_asteroid);
            }

            // при следующем вбрасывании астероидов должно быть больше
            DROP_CNT += INC_DROP;
            // обновить статистику
            doUpdateStatistic();
        }

        public function update(event : Event):void
        {
            var zone:String, obj2:BasicObject, i:Number, fragment:SmallAsteroid, ex_mc:Explosion;
            var asteroid_count = 0;
            // Проходим по всему массиву созданных объектов
            // и заставляем каждого сдвинуться в своем направлении
            for each (var obj:BasicObject in all_moving)
            {
                // смещаемся
                obj.move();

                if (obj.type != 'earth')
                {
                    // перед тем, как сдвинуться удалим запись об этом объекте из секторов
                    for (zone in obj.sectors)
                    {
                        delete all_sectors[zone][obj.name];
                    }

                    if (obj.hp>0)
                    {
                        if (obj.type == 'asteroid')
                        {
                            asteroid_count++;
                        }

                        if (obj.x<(-width/2) || obj.x>(width/2) || obj.y<(-height/2) || obj.y>(height/2))
                        {
                            obj.hp = 0;
                        }

                        if (obj.velocity.x!=0 && obj.velocity.y!=0 && Math.abs(obj.velocity.x)<0.4 && Math.abs(obj.velocity.y)<0.4)
                        {
                            obj.velocity.mulScalar(1.5); // увеличиваем скорость
                        }

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

                                       if (obj2.type == 'earth' && obj.type == 'asteroid')
                                       {
                                           obj.hp = 0;

                                            // на его место аттачим "падающий" астероид
                                            var asteroidFall:AsteroidFall = new AsteroidFall();
                                            asteroidFall.init(obj, this.earth);
                                            addChild(asteroidFall);
                                            asteroidFall.addEventListener("CHANGE_EARTH_HP", doUpdateStatistic);
                                        }
                                        else if(obj2.type == 'asteroid')
                                        {
                                            // столкнулись
                                            // делаем отскок
                                            resolve(obj, obj2);
                                            obj.hp -=15;
                                            obj2.hp -= 15;
                                        }
                                        else if(obj2.type == 'turret')
                                        {
                                            pullBalls(obj, obj2);
                                            obj.hp -=15;
                                            obj2.hp -= 15;
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
                        deleteFromObjList(obj);

                        if (obj.type == 'turret' || obj.type == 'rocket')
                        {
                            ex_mc = new ExplosionRocket();
                        }
                        else
                        {
                            // аттачим несколько случайных осколков (5-15)
                            i = Math.max(5, Math.floor(Math.random()*15));
                            while (i--)
                            {
                                fragment = new SmallAsteroid(); // создаем новый осколок
                                fragment.init(obj);     // инициализация параметров
                                addChild(fragment);     // добавляем его на наш мувиклип
                            }

                            // аттачим мувик взрыва
                            ex_mc = new ExplosionObject();
                        }
                        ex_mc.init(obj);
                        addChild(ex_mc);
                        // удаляем сам мувик астероида
                        removeChild(obj);
                        // учитываем влияние ударной волны взрыва на другие объекты
                        addExplosion(obj.x, obj.y, obj.getMassa());
                    }
                }
            }

            // если осталось мало астероидов, то вбрасываем еще
            if (asteroid_count < DROP_CNT)
            {
                dropSeveralAsteroids();
            }
        }

        //добавляет ссылку на объект в секторах
        public function addObjectInSectors(obj:BasicObject)
        {
            var zone:String;
            all_moving.push(obj);
            obj.calcSectors();
            for (zone in obj.sectors)
            {
                if (!all_sectors[zone])
                {
                    // такого сектора еще не было, создадим
                    all_sectors[zone] = {};
                }
                all_sectors[zone][obj.name] = obj;
            }
        }

        // удаляет объект из списка живых
        private function deleteFromObjList(obj:Object)
        {
            var counter:Number;
            for (counter = 0; counter < all_moving.length; counter++)
            {
                if (all_moving[counter] == obj)
                {
                    all_moving.splice(counter,1);
                    break;
                }
            }
            dispatchEvent(new Event("UPDATE_STATISTIC"));
        }

        // Генерит событие "нужно обновить статистику"
        private function doUpdateStatistic(event:Event = undefined)
        {
            dispatchEvent(new Event("UPDATE_STATISTIC"));
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

            var lineOfSight:Vector_h = new Vector_h(ball1.x - ball2.x, ball1.y - ball2.y);
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
        function pullBalls(ball1:BasicObject, ball2:BasicObject, add_random:Number=0):void
        {
            var v:Vector_h = new Vector_h(ball1.x-ball2.x, ball1.y-ball2.y);
            var distance:Number = v.magnitude();
            var min_distance:Number = ball1.radius + ball2.radius;
            if (distance > min_distance) return; // не пересекаются
            v.mulScalar((0.1+min_distance-distance)/distance);
            ball1.x += v.x;
            ball1.y += v.y;
            // добавить небольшой рандом в положение ball1
            if (add_random > 0)
            {
                ball1.velocity.addVector(v.getUnitVector());
                ball1.x += (Math.random()-0.5)*add_random;
                ball1.y += (Math.random()-0.5)*add_random;
            }
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
                        if ((! one[obj.name]) && (obj.type == 'asteroid'))
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

        // Добавить турель в игру
        public function addTurret(x:Number, y:Number, turret_type:Number)
        {
            var obj:TurretObject;
            switch(turret_type)
            {
                case 1:
                    obj = new TurretLaser();
                break;

                case 2:
                    obj = new TurretRocket();
                break;

                case 3:
                    obj = new TurretBastion();
                break;
            }

            // зададим координаты
            obj.x = x;
            obj.y = y;
            obj.type = 'turret';
            addChild(obj);  // добавляем на наш мувиклип

            // теперь двигаем турель так, чтобы она не пересекалась ни с одинм объектом на поле
            var check_again:Boolean;
            var cnt:Number=0;
            var s:String, obj2:BasicObject;
            do
            {
                check_again=false;
                // Просим пересчитать в какие сектора попала турель
                obj.calcSectors();
                for (s in obj.sectors)
                {
                    if (!check_again)
                    {
                        // еще не обнаружили столкновение
                        // проверяем на столкновение со всеми объектами в секторе
                        for each (obj2 in all_sectors[s])
                        {
                            if (obj.checkCollision(obj2))
                            {
                                // столкнулись
                                // отодвинем, чтобы не пересекались
                                pullBalls(obj, obj2, cnt);
                                // проверяем на столкновения повторно
                                check_again=true;
                                // турель сдвинута, дальше проверять эти сектора нет смысла
                                break;
                            }
                        }
                    }
                }
                cnt++;
             } while (check_again);
             // Разместили турель так, что она ни с кем не пересекается

            addObjectInSectors(obj);
            // обновить статистику
            doUpdateStatistic();
        }
    }
}
