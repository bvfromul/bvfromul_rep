package main
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.setTimeout;
    import flash.utils.clearTimeout;
    import flash.filters.GlowFilter;

    dynamic public class BasicObject extends MovieClip
    {
        public var radius:Number;                                    // радиус
        public var sectors:Object;                                   // какие сектора пересекает объект
        public var velocity:Vector_h;                                // вектор движения
        public var type;                                             // тип объекта

        internal var hpLine:HPline;                                  // мувик полоски уровня жизни
        internal var hideTimeout:Number = GameConst.hideTimeout;     // id таймера на удаление полоски уровня жизни
        internal var mHP:Number;
        internal var tkHP:Number;

        public function BasicObject()
        {
            hpLine = new HPline(); // создаем мувик полоски жизни
            hideInfo();
            addChild(hpLine); // добавим
            velocity = new Vector_h(); // создаем вектор
            addEventListener(MouseEvent.MOUSE_OVER, showInfo);// при наведении мышки - показать
            addEventListener(MouseEvent.MOUSE_OUT, hideInfo); // при уходе мышки - убрать
        }

        // Вычисляет расстояние до другого объекта в квадрате
        // Функция sqrt довольно медленная и быстрее оперировать расстоянием в квадрате
        public function distance2(obj2:BasicObject):Number
        {
            var dx:Number = x - obj2.x;
            var dy:Number = y - obj2.y;
            return dx*dx + dy*dy;
        }

        // Вычисляет расстояние до другого объекта
        public function distance(obj2:BasicObject):Number
        {
            return Math.sqrt( distance2(obj2) );
        }

        // Определяет, столкнулись два объекта или нет
        public function checkCollision(obj2:BasicObject):Boolean
        {
            var d2:Number = distance2(obj2); // квадрат расстояния
            // сумма радиусов - минимально возможное расстояние между объектами
            var dr:Number = radius + obj2.radius;
            // если расстояние между объектами меньше суммы их радиусов - столкновение
            return (d2 < dr*dr);
        }

        public function getMassa():Number
        {
            var r:Number = radius;
            return (4/3*Math.PI*r*r*r)/100;       // масса шара
        }

        // Пересчитывает, какие сектора пересекает объект
        public function calcSectors():void
        {
            var dx:Number, dy:Number;
            var x1:Number, y1:Number;
            var zone:String;
            sectors = {};      // сбрасываем список секторов
            for (dx = -1; dx <= 1; dx += 2)
            {
                for (dy = -1; dy <= 1; dy += 2)
                {
                    // вычисляем координату угла (центр+радиус)
                    x1 = x + radius*dx;
                    y1 = y + radius*dy;
                    // название сектора будет в виде "x_y"
                    zone = Math.floor(x1/100)+"_"+Math.floor(y1/100);
                    sectors[zone]=true;   // запоминаем этот сектор
                }
            }
        }

        // Отображает информацию об объекте
        public function showInfo(event:Event = undefined) :void
        {
            if (!mHP)
            {
                // нет уровня жизни, нечего показывать
                hideInfo(); // спрятать полоску, если была
                return;
            }

            if (hideTimeout)
            {
                // выключить таймер на удаление полоски
               clearTimeout(hideTimeout);
               hideTimeout=0;
             }

            hpLine.visible=true;
            // зная радиус объекта, располагаем полоску сверху

            hpLine.x=-radius/2+hpLine.width/4;
            hpLine.y = -radius-20;
            this.hpLine.gotoAndStop(Math.floor(tkHP/mHP*100)+1);    // уровень жизни в процентах
        }

        // Убирает информацию об объекте
        public function hideInfo(event:Event = undefined) :void
        {
            if (!(hpLine && hpLine.visible))
            {
                // полоска не создана или не видна
                hideTimeout = setTimeout(graphics.clear, 1000);
                return;
            }

            if (!hideTimeout)
            {
                hideTimeout=setTimeout(hideInfoNow, 1000);
            }

            hpLine.visible=false; // прячем
        }

        // Немедленно убирает полоску уровня жизни
        public function hideInfoNow():void
        {
            if (hpLine)
            {
                hpLine.visible=false; // прячем
            }
            hideTimeout=0;
        }

        // set/get для текущего уровня жизни
        public function set hp(newHP:Number):void
        {
            tkHP=Math.max(0, newHP); // уровень жизни не может быть меньше нуля
            if (hpLine && hpLine.visible)
            {
                // нарисована полоска уровня жизни
                showInfo(); // нужно обновить информацию
            }
            showCriticalHP();
        }

        public function get hp():Number
        {
            return tkHP;
        }

        // set/get для максимального уровня жизни
        public function set maxHP(new_maxHP:Number) :void
        {
            mHP=new_maxHP;
            if (hpLine && hpLine.visible)
            {
                // нарисована полоска уровня жизни
                showInfo(); // нужно обновить информацию
            }
        }

        public function get maxHP():Number
        {
            return mHP;
        }

        // Включает красную подсветку, если уровень жизни критический <33%
        function showCriticalHP():void
        {
            var percent:Number;
            if (!mHP)
            {
                // не установлен maxHP
                return;
            }

            percent = hp / mHP; // процент уровня жизни 0..1
            if (percent >= 0.33)
            {
                // уровень жизни не критический
                return;
            }

            // уровень жизни критический
            // создаем свечение, яркость которого (alpha) зависит от процента HP
            var myFilters:Array = [];
            myFilters.push(new GlowFilter(0xFF0000, 1-percent*3, 18,18));
            if (this["bg"])
            {
                // если есть фоновая картинка, то подсвечиваем ее
                this.bg.filters = myFilters;
            }
            else
            {
                // иначе объект целиком
                filters = myFilters;
            }
        }

        // Переместить объект. Переопределяется в двигающихся наследниках
        public function move():void
        {

        }
    }
}
