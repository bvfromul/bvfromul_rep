package main
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;

    dynamic public class BasicObject extends MovieClip
    {
        public var radius:Number; // радиус
        public var sectors:Object;  // какие сектора пересекает объект

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
        public function CheckCollision(obj2:BasicObject):Boolean
        {
            var d2:Number = distance2(obj2); // квадрат расстояния
            // сумма радиусов - минимально возможное расстояние между объектами
            var dr:Number = radius + obj2.radius;
            // если расстояние между объектами меньше суммы их радиусов - столкновение
            return (d2 < dr*dr);
        }

        function getMassa():Number
        {
            var r:Number = radius;
            return (4/3*Math.PI*r*r*r)/100;       // масса шара
        }

        // Пересчитывает, какие сектора пересекает объект
        public function CalcSectors():void
        {
            var dx:Number, dy:Number;
            var x1:Number, y1:Number;
            var s:String;
            sectors = new Object();      // сбрасываем список секторов
            for (dx = -1; dx <= 1; dx += 2)
            {
                for (dy = -1; dy <= 1; dy += 2)
                {
                    // вычисляем координату угла (центр+радиус)
                    x1 = x + radius*dx;
                    y1 = y + radius*dy;
                    // название сектора будет в виде "x_y"
                    s = Math.floor(x1/100)+"_"+Math.floor(y1/100);
                    sectors[s]=true;   // запоминаем этот сектор
                }
            }
        }

        var tkHP:Number, mHP:Number; // текущий и максимальный уровни жизни
        var hp_mc:HPline;    // мувик полоски уровня жизни

        public function BasicObject()
        {
            addEventListener(MouseEvent.MOUSE_OVER, ShowInfo);// при наведении мышки - показать
            addEventListener(MouseEvent.MOUSE_OUT, HideInfo); // при уходе мышки - убрать
        }

        // Отображает информацию об объекте
        public function ShowInfo(e:Event = undefined) :void
        {
            if (!mHP)
            { // нет уровня жизни, нечего показывать
                HideInfo(); // спрятать полоску, если была
                return;
            }

            if (!hp_mc)
            { // плоска еще не создавалась
                hp_mc = new HPline(); // создаем мувик полоски жизни
                addChild(hp_mc); // добавим
            }

            hp_mc.visible=true;
            // зная радиус объекта, располагаем полоску сверху
            hp_mc.width=radius*2;
            hp_mc.x=-radius;
            hp_mc.y=-radius-hp_mc.height;
            hp_mc.gotoAndStop(Math.floor(tkHP/mHP*100)+1);    // уровень жизни в процентах
        }

        // Убирает информацию об объекте
        public function HideInfo(e:Event = undefined) :void
        {
            if (!(hp_mc && hp_mc.visible)) // полоска не создана или не видна
                return;

            hp_mc.visible=false; // прячем
        }

        // set/get для текущего уровня жизни
        public function set HP(newHP:Number) :void
        {
            tkHP=Math.max(0, newHP); // уровень жизни не может быть меньше нуля
            if (hp_mc && hp_mc.visible) // нарисована полоска уровня жизни
                ShowInfo(); // нужно обновить информацию
        }

        public function get HP():Number
        {
            return tkHP;
        }

        // set/get для максимального уровня жизни
        public function set maxHP(new_maxHP:Number) :void
        {
            mHP=new_maxHP;
            if (hp_mc && hp_mc.visible) // нарисована полоска уровня жизни
                ShowInfo(); // нужно обновить информацию
        }

        public function get maxHP():Number
        {
            return mHP;
        }
    }
}
