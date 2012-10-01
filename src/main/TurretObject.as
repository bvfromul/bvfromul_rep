package main
{
    import flash.events.Event;
    import main.BasicObject;

    dynamic public class TurretObject extends BasicObject
    {
        public var trgtRadius:Number;               // радиус поражения цели
        public var maxWeaponRecharge:Number;        // максимальное значение заряда пушки
        public var turretType:Number;               // тип турели
        public var trgt:BasicObject;                // цель
        public var cost:Number;                     // сколько монет стоит эта турель
        var weaponRecharge:Number;                  // счетчик перезарядки пушки
        var velocitySlowdown:Number = 0.91;         // коэффициент уменьшения скорости
        var findBigObjects:Boolean;                 // приоритенее объекты с большим кол-вом уровни жизни (для турелей)

        public function TurretObject()
        {
            turretType=3; // тип объекта "турель"
            // вычислим наш радиус, основываясь на размере картинки
            radius = Math.floor((this.bg.width+this.bg.height)/4);
            // запустим процесс зарядки пушки
            weaponRecharge=0;
            if (this.bg["rechargeClip"])
            {
                this.bg.rechargeClip.gotoAndStop(1);
            }
        }

        // Переопределяем функцию "Переместиться"
        override public function move():void
        {
            var vector:Vector_h, angle:Number;
            // передвигаться турель может только если ее толкнули
            x += velocity.x;
            y += velocity.y;
            // "гасим" скорость, турель пытается удержаться на своей позиции
            if (Math.abs(velocity.x)>0.4) velocity.x *= velocitySlowdown;
            else velocity.x=0;
            if (Math.abs(velocity.y)>0.4) velocity.y *= velocitySlowdown;
            else velocity.y=0;

            // перезарядка пушки
            if (weaponRecharge < maxWeaponRecharge)
            {
                weaponRecharge++;
            }
            // отобразим процент заряда пушки
            if (maxWeaponRecharge > 0)
            {
                this.bg.rechargeClip.gotoAndStop(Math.floor(weaponRecharge/maxWeaponRecharge*100)+1);
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
                    vector = new Vector_h(trgt.x-x, trgt.y-y);
                    if (vector.magnitude() > trgtRadius)
                    {
                        // цель ушла из радиуса поражения
                        trgt = undefined; // будем искать другую
                    }
                    else
                    {
                        // повернемся к цели
                        // на сколько нужно повернуться до цели
                        angle = vector.getDirection() - this.bg.rotation;
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
                        if (Math.abs(angle)<=5 && weaponRecharge>=maxWeaponRecharge)
                        {
                            // пушка наведена на цель и заряжена
                            fire();	// ПЛИИИИИИ!!!!!
                        }
                    }
                }
            }
            if (! trgt && trgtRadius > 0)
            {
                // нужно искать новую цель
                findTarget();
            }
        }

        // Ищет цель в радиусе trgtRadius
        public function findTarget():void
        {
            var i:Number, j:Number;
            var obj:BasicObject, sector:String;
            var vector:Vector_h;
            var list:Array = []; // список возможных целей
            var o:Object;

            // пробегаемся по всем секторам, которые попадают в радиус поиска цели
            for (i = Math.floor((x - trgtRadius) / 100); i <= Math.floor((x + trgtRadius) / 100); i++)
            {
                for (j = Math.floor((y - trgtRadius) / 100); j <= Math.floor((y + trgtRadius) / 100); j++)
                {
                    // название сектора
                    sector = i+"_"+j;
                    for each (obj in (parent as Sky).allSectors[sector])
                    {
                        // все объекты в секторе
                        if ((obj.type == 'asteroid') && (obj.hp > 0))
                        {
                            // нас интересуют только "живые" астероиды
                            // получим основные характеристики для выбора
                            o = {};
                            o.obj = obj;
                            // создадим вектор от нас до цели
                            vector = new Vector_h(obj.x-x, obj.y-y);
                            // добавим скорость
                            vector.addVector(obj.velocity);
                            // оцениваем по расстоянию до объекта, плюс HP
                            if (findBigObjects)
                            {
                                // приоритенее "толстые" объекты
                                o.len = vector.magnitude() - obj.maxHP;
                            }
                            else
                            {
                                // приоритетнее "дохлые" объекты
                                o.len = vector.magnitude() + obj.hp;
                            }
                            // добавляем в массив возможных целей
                            list.push(o);
                        }
                    }
                }
            }
            if (! list.length)
            {
                // не обнаружилось ни одной цели
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
            graphics.drawCircle(0,0, trgtRadius);
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
