package main
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Point;

    dynamic public class Panel extends Sprite
    {
        public var score:Number;               // сколько игрок набрал очков
        public var money:Number;               // сколько игрок имеет денег
        public var minimap:Minimap;

        internal var gameSnd:Sound;            // пространственные звуки

        private var kfMoney:Number;            // коэффициент HP/money
        private var twinklingCnt:Number;       // счетчик мерцания стоимости
        private var twinklingNm:String;        // для какой турели мерцает стоимость
        private var parentClass:Sky;           // ссылка на главный класс

        public function Panel(sky:Sky)
        {
            kfMoney = 10;
            money=GameConst.startMoney;
            score=0;
            parentClass = sky;
            // Обновляем статистику по событию от главного класса
            parentClass.addEventListener("UPDATE_STATISTIC", update);

            //добавляем минимапу
            minimap:Minimap;
            minimap = new Minimap(parentClass);
            minimap.x = 52;
            minimap.y = 369;
            this.addChild(minimap);

            this.ascteroidsLabel.text = parentClass.allMoving.length > 1 ? String(parentClass.allMoving.length - 1) : "0";
            this.earthsLabel.text = parentClass.earth.hp.toString();
            this.earthHpLine.gotoAndStop(Math.floor(parentClass.earth.hp / parentClass.earth.maxHP * 100) + 1);

            // даем возможность "перетащить" турели с панели управления на игровое поле
            var i:Number = 1;
            while (this["turret" + i])
            {
                // есть такая турель
                // запомним координаты, чтобы после перетаскивания вернуть на место
                this["turret"+i].oldX = this["turret"+i].x;
                this["turret"+i].oldY = this["turret"+i].y;
                this["turret"+i].hp = this["turret"+i].maxHP = 0; // нет полоски с HP
                // для перетаскивания перехватываем нажатие и отпускание кнопки мышки
                this["turret"+i].addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
                this["turret" + i].addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
                this["costTurrret"+i].text = this["turret"+i].cost;
                i++;  // переходим к следующей турели
            }

            // инициализируем звуки
            gameSnd = new Sound();
            gameSnd.init(parentClass.stage.stageWidth, parentClass.stage.stageHeight);
        }

        // обновить статистику
        public function update(event:Event=undefined):void
        {
            // Количество астероидов в игре (один объект в allMoving – это сама земля)
            this.ascteroidsLabel.text = parentClass.asteroidCount.toString();
            // Уровень жизни земли
            this.earthsLabel.text = parentClass.earth.hp.toString();
            // Прогресбар уровня жизни земли
            this.earthHpLine.gotoAndStop(Math.floor(parentClass.earth.hp / parentClass.earth.maxHP * 100) + 1);
            // Счет
            this.scoreLabel.text = Math.floor(score).toString();
            // деньги
            this.moneyLabel.text = money.toString();
            // подсветим красным турели, которые сейчас нельзя поставить из-за нехватки денег
            var i:Number = 1;
            var ok:Boolean;
            while (this["turret" + i])
            {
                // есть такая турель
                ok = this["turret"+i].cost <= money;
                this["turret"+i].transform.colorTransform = new ColorTransform(1,1,1, 1, ok?0:200,0,0, 0);
                this["costTurrret"+i].textColor = ok ? 0xFFFFFF : 0xFF0000;
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
        function twinkling(target:String):void
        {
            if (twinklingCnt)
            {
                // уже что-то мерцает
                stopTwinkling();    // прекращаем
            }
            twinklingNm=target;
            twinklingCnt=21;   // мерцаем секунду
            // добавляем обработку события по ENTER_FRAME
            addEventListener(Event.ENTER_FRAME, doTwinkling);
        }

        // функция мерцания
        function doTwinkling(event:Event):void
        {
            if (--twinklingCnt)
            {
                // еще мерцаем
                this["money_"+twinklingNm].visible = this.moneyLabel.visible = !this.moneyLabel.visible;
            }
            else
            {
                // закончили
                stopTwinkling();
            }
        }
        // функция окончания мерцания
        function stopTwinkling():void
        {
            // возвращаем видимость полей
            this.moneyLabel.visible = this["money_"+twinklingNm].visible = true;
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
            event.currentTarget.x = event.currentTarget.oldX;
            event.currentTarget.y = event.currentTarget.oldY;
            // если кинули правее панели управления, т.е. на игровую область
            if (x > 100)
            {
                // то добавим эту турель в игру
                if (decMoney(event.currentTarget.cost))
                {
                    // монет хватает
                    parentClass.addTurret(x - parentClass.x, y - parentClass.y, event.currentTarget.turretType);
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
