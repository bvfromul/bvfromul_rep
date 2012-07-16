package main
{
    import flash.display.Sprite;
    import flash.events.Event;
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

        }

        // обновить статистику
        public function update(event:Event):void
        {
            // Количество астероидов в игре (один объект в all_moving – это сама земля)
            this.ascteroids_label.text = sky_mc.all_moving.length>1 ? String(sky_mc.all_moving.length-1) : "";
            // Уровень жизни земли
            //this.earths_label.text = String(sky_mc.earth.hp);
            // Прогресбар уровня жизни земли
            //this.earth_hp.gotoAndStop(Math.floor(sky_mc.earth.hp/sky_mc.earth.maxHP*100)+1);
        }
    }
}
