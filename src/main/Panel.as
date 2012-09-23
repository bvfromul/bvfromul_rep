package main
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import main.Sky;
    import flash.geom.ColorTransform;
    import flash.geom.Point;

    dynamic public class Panel extends Sprite
    {
        const START_MONEY:Number = 30000; // сколько монет выдается в начале игры
        public var score:Number;        // сколько игрок набрал очков
        public var money:Number;        // сколько игрок имеет денег
        public var minimap:Minimap;

        private var kfMoney:Number;             // коэффициент HP/money
        private var twinkling_cnt:Number;       // счетчик мерцания стоимости
        private var twinkling_nm:String;        // для какой турели мерцает стоимость
        var sky_mc:Sky;                         // ссылка на главный класс
        var gameSnd:Sound;                      // пространственные звуки

        public function Panel(sky:Sky)
        {
            kfMoney=10;
            money=START_MONEY;
            score=0;
            sky_mc = sky;
            // Обновляем статистику по событию от главного класса
            sky_mc.addEventListener("UPDATE_STATISTIC", update);

            //добавляем минимапу
            minimap:Minimap;
            minimap = new Minimap(sky_mc);
            minimap.x = 52;
            minimap.y = 369;
            this.addChild(minimap);

            this.ascteroids_label.text = sky_mc.all_moving.length > 1 ? String(sky_mc.all_moving.length - 1) : "0";
            this.earths_label.text = sky_mc.earth.hp.toString();
            this.earth_hp.gotoAndStop(Math.floor(sky_mc.earth.hp / sky_mc.earth.maxHP * 100) + 1);

            // даем возможность "перетащить" турели с панели управления на игровое поле
            var i:Number = 1;
            while (this["t" + i])
            {
                // есть такая турель
                // запомним координаты, чтобы после перетаскивания вернуть на место
                this["t"+i].old_x = this["t"+i].x;
                this["t"+i].old_y = this["t"+i].y;
                this["t"+i].hp = this["t"+i].maxHP = 0; // нет полоски с HP
                // для перетаскивания перехватываем нажатие и отпускание кнопки мышки
                this["t"+i].addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
                this["t" + i].addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
                this["money_t"+i].text = this["t"+i].cost;
                i++;  // переходим к следующей турели
            }

            // инициализируем звуки
            gameSnd = new Sound();
            gameSnd.init(sky_mc.stage.stageWidth, sky_mc.stage.stageHeight);
        }

        // обновить статистику
        public function update(event:Event=undefined):void
        {
            // Количество астероидов в игре (один объект в all_moving – это сама земля)
            this.ascteroids_label.text = sky_mc.asteroid_count.toString();
            // Уровень жизни земли
            this.earths_label.text = sky_mc.earth.hp.toString();
            // Прогресбар уровня жизни земли
            this.earth_hp.gotoAndStop(Math.floor(sky_mc.earth.hp / sky_mc.earth.maxHP * 100) + 1);
            // Счет
            this.score_label.text = Math.floor(score).toString();
            // деньги
            this.money_label.text = money.toString();
            // подсветим красным турели, которые сейчас нельзя поставить из-за нехватки денег
            var i:Number = 1;
            var ok:Boolean;
            while (this["t" + i])
            {
                // есть такая турель
                ok = this["t"+i].cost <= money;
                this["t"+i].transform.colorTransform = new ColorTransform(1,1,1, 1, ok?0:200,0,0, 0);
                this["money_t"+i].textColor = ok ? 0xFFFFFF : 0xFF0000;
                i++;
            }
        }

        // Добавляет очки
        public function addPoints(asteroidHp:Number):void
        {
            score += asteroidHp/10;    // добавляем очки
            money += Math.floor(asteroidHp/kfMoney);   // и монеты
            kfMoney+=0.01;  // чем больше цничтожается астероидов, тем меньше поступает монет
            update();   // обновить статистику
        }

        // Вычитает монеты
        public function decMoney(sum:Number):Boolean
        {
            if (sum > money)
            {
                // нет столько монет
                return false;
            }
            money -= sum;
            update();

            return true;
        }

        // Мерцает стоимость указанной турели
        function twinkling(nm:String):void
        {
            if (twinkling_cnt)
            {
                // уже что-то мерцает
                stopTwinkling();    // прекращаем
            }
            twinkling_nm=nm;
            twinkling_cnt=21;   // мерцаем секунду
            // добавляем обработку события по ENTER_FRAME
            addEventListener(Event.ENTER_FRAME, doTwinkling);
        }

        // функция мерцания
        function doTwinkling(event:Event):void
        {
            if (--twinkling_cnt)
            {
                // еще мерцаем
                this["money_"+twinkling_nm].visible = this.money_label.visible = !this.money_label.visible;
            }
            else
            { // закончили
                stopTwinkling();
            }
        }
        // функция окончания мерцания
        function stopTwinkling():void
        {
            // возвращаем видимость полей
            this.money_label.visible = this["money_"+twinkling_nm].visible = true;
            // удаляем событие
            removeEventListener(Event.ENTER_FRAME, doTwinkling);
        }

        function handleMouseDown(event:Event):void
        {
            // по какому именно объекту кликнули записано в событии: event.currentTarget
            // начнем перетаскивание
            event.currentTarget.startDrag(true);
            // поднимем эту турель на самый верх, чтобы при перетаскивании
            // она не проходила под другими объектами
           // setChildIndex(event.currentTarget, numChildren - 1);
            this.swapChildren((event.currentTarget as Sprite), this.getChildAt(this.numChildren-1));
        }

        function handleMouseUp(event:Event):void
        {
            // прекратили перетаскивание
            event.currentTarget.stopDrag();
            // запомним координаты
            var x:Number = event.currentTarget.x;
            var y:Number = event.currentTarget.y;
            // вернем турель на место
            event.currentTarget.x = event.currentTarget.old_x;
            event.currentTarget.y = event.currentTarget.old_y;
            // если кинули правее панели управления, т.е. на игровую область
            if (x > 100)
            {
                // то добавим эту турель в игру
                if (decMoney(event.currentTarget.cost))
                {
                    // монет хватает
                    sky_mc.addTurret(x - sky_mc.x, y - sky_mc.y, event.currentTarget.turret_type);
                    gameSnd.Play2DSnd('addship', x-stage.stageWidth/2,y-stage.stageHeight/2);
                }
                else
                {
                    // недостаточно монет
                    twinkling(event.currentTarget.name);
                    gameSnd.Play2DSnd('error', 1,1);
                }
            }
        }

        // проигрывает указанный звук, местоположение определяется по объекту
        public function PlaySnd(sndName:String, obj:Sprite):void
        {
            var point:Point = obj.localToGlobal(new Point(0,0));
            gameSnd.Play2DSnd(sndName, point.x-stage.stageWidth/2, point.y-stage.stageHeight/2);
        }
    }
}
