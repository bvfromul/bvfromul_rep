package main
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import main.Sky;

    dynamic public class Panel extends Sprite
    {
        var sky_mc:Sky;  // ссылка на главный класс

        public function Panel(sky:Sky)
        {
            sky_mc = sky;
            // Обновляем статистику по событию от главного класса
            sky_mc.addEventListener("UPDATE_STATISTIC", update);

            //добавляем минимапу
            var minimap:Minimap;
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
                this["t"+i].addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
                i++;  // переходим к следующей турели
            }
        }

        // обновить статистику
        public function update(event:Event):void
        {
            // Количество астероидов в игре (один объект в all_moving – это сама земля)
            this.ascteroids_label.text = sky_mc.all_moving.length>1 ? String(sky_mc.all_moving.length-1) : "0";
            // Уровень жизни земли
            this.earths_label.text = sky_mc.earth.hp.toString();
            // Прогресбар уровня жизни земли
            this.earth_hp.gotoAndStop(Math.floor(sky_mc.earth.hp/sky_mc.earth.maxHP*100)+1);
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
                sky_mc.addTurret(x-sky_mc.x, y-sky_mc.y, event.currentTarget.turret_type);
            }
        }
    }
}
