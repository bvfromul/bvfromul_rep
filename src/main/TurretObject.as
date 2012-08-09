package main
{
    import flash.events.Event;
    import main.BasicObject;
    import main.Vector_h;

    dynamic public class TurretObject extends BasicObject
    {
        public var trgt_radius :Number;               // радиус поражения цели
        public var max_weapon_recharge:Number;        // максимальное значение заряда пушки
        public var turret_type :Number;               // тип турели: 1-лазерная, 2-ракетная
        public var trgt        :BasicObject;         // цель
        var weapon_recharge:Number;                   // счетчик перезарядки пушки
        var velocitySlowdown:Number = 0.91;	// коэффициент уменьшения скорости
        var findBigObjects:Boolean;	// приоритенее объекты с большим кол-вом уровни жизни (для турелей)

        public function TurretObject()
        {
            turret_type=3; // тип объекта "турель"
            // вычислим наш радиус, основываясь на размере картинки
            radius = Math.floor((this.bg.width+this.bg.height)/4);
            // запустим процесс зарядки пушки
            weapon_recharge=0;
            if (this.bg["recharge_mc"])
            {
                this.bg.recharge_mc.gotoAndStop(1);
            }
        }

        // Переопределяем функцию "Переместиться"
        override public function move():void
        {
            var v:Vector_h, angle:Number;
            // передвигаться турель может только если ее толкнули
            x += velocity.x;
            y += velocity.y;
            // "гасим" скорость, турель пытается удержаться на своей позиции
            if (Math.abs(velocity.x)>0.4) velocity.x *= velocitySlowdown;
            else velocity.x=0;
            if (Math.abs(velocity.y)>0.4) velocity.y *= velocitySlowdown;
            else velocity.y=0;

            // перезарядка пушки
            if (weapon_recharge < max_weapon_recharge)
            {
                weapon_recharge++;
            }
            // отобразим процент заряда пушки
            if (max_weapon_recharge > 0)
            {
                this.bg.recharge_mc.gotoAndStop(Math.floor(weapon_recharge/max_weapon_recharge*100)+1);
            }

            if (trgt)
            {
                // есть цель
                if (!(trgt.hp > 0))
                {
                    // у цели нет HP... уничтожена?
                    trgt = undefined; // будем искать другую
                }
                else
                {
                    // цель еще жива
                    // создадим вектор до цели
                    v = new Vector_h(trgt.x-x, trgt.y-y);
                    if (v.magnitude() > trgt_radius)
                    {
                        // цель ушла из радиуса поражения
                        trgt = undefined; // будем искать другую
                    }
                    else
                    {
                        // повернемся к цели
                        // на сколько нужно повернуться до цели
                        angle = v.getDirection() - this.bg.rotation;
                        // проблема с переходом -180...180
                        if (angle > 180)
                        {
                            angle-=360;
                        }
                        else if (angle < -180)
                        {
                            angle+=360;
                        }
                        if (Math.abs(angle) > 0)
                        {
                            // за раз поворачиваемся не более чем на 10 градусов
                            this.bg.rotation += Math.abs(angle)>10?(angle>0?10:-10):angle;
                        }
                        if (Math.abs(angle)<=5 && weapon_recharge>=max_weapon_recharge)
                        {
                            // пушка наведена на цель и заряжена
                            fire();	// ПЛИИИИИИ!!!!!
                        }
                    }
                }
            }
            if (! trgt && trgt_radius > 0)
            {
                // нужно искать новую цель
                findTarget();
            }
        }

        // Ищет цель в радиусе trgt_radius
        public function findTarget():void
        {
            var i:Number, j:Number;
            var obj:BasicObject, s:String;
            var v:Vector_h;
            var list:Array = []; // список возможных целей
            var o:Object;

            // пробегаемся по всем секторам, которые попадают в радиус поиска цели
            for (i = Math.floor((x - trgt_radius) / 100); i <= Math.floor((x + trgt_radius) / 100); i++)
            {
                for (j = Math.floor((y - trgt_radius) / 100); j <= Math.floor((y + trgt_radius) / 100); j++)
                {
                    // название сектора
                    s = i+"_"+j;
                    for each (obj in (parent as Sky).all_sectors[s])
                    {
                        // все объекты в секторе
                        if ((obj.type == 'asteroid') && (obj.hp > 0))
                        {
                            // нас интересуют только "живые" астероиды
                            // получим основные характеристики для выбора
                            o = {};
                            o.obj = obj;
                            // создадим вектор от нас до цели
                            v = new Vector_h(obj.x-x, obj.y-y);
                            // добавим скорость
                            v.addVector(obj.velocity);
                            // оцениваем по расстоянию до объекта, плюс HP
                            if (findBigObjects)
                            {
                                // приоритенее "толстые" объекты
                                o.len = v.magnitude() - obj.maxHP;
                            } else
                            {
                                // приоритетнее "дохлые" объекты
                                o.len = v.magnitude() + obj.hp;
                            }
                            // добавляем в массив возможных целей
                            list.push(o);
                        }
                    }
                }
            }
            if (! list.length){ // не обнаружилось ни одной цели
                return;
            }
            // цели отсортируем по расстоянию
            list.sortOn("len", Array.NUMERIC);
            // берем "ближайшую"
            trgt = list[0].obj;
        }

        // Выстрел по цели
        public function fire():void
        {
            // функция переопределяется в последующих классах турелей
        }

        // Переопределяем функцию отображения информации об объекте
        // добавим в турель показ зоны поражения
        override public function showInfo(event:Event = undefined):void
        {
            graphics.clear();
            graphics.lineStyle(3, 0x0000FF, 0.3);
            graphics.drawCircle(0,0, trgt_radius);
            // вызываем функцию ShowInfo предка
            super.showInfo(event);
        }

        // при убирании информации об объекте нужно стереть круг
        override public function hideInfoNow():void
        {
            graphics.clear();
            super.hideInfoNow();
        }

        public function remove():void
        {
            if (parent)
            {
                parent.removeChild(this);
            }
        }
    }
}
