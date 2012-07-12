package main
{
    import flash.display.Sprite;
    import flash.events.Event;
    import main.Sky;

    dynamic public class Panel extends Sprite
    {
        var sky_mc:Sky;  // ссылка на главный класс

        public function panel()
        {
            sky_mc = root.sky;
            // Обновляем статистику по событию от главного класса
            sky_mc.addEventListener("UPDATE_STATISTIC", update);
        }

        // обновить статистику
        public function update(event:Event):void
        {
            // Количество астероидов в игре (один объект в all_moving – это сама земля)
            this.ascteroids_label.text = sky_mc.all_moving.length>1 ? sky_mc.all_moving.length-1 : "";
            // Уровень жизни земли
            this.earths_label.text = sky_mc.earth.hp;
            // Прогресбар уровня жизни земли
            this.earth_hp.gotoAndStop(Math.floor(sky_mc.earth.hp/sky_mc.earth.maxHP*100)+1);
        }
    }
}
