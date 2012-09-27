// Луч лазера
package main
{
    import flash.display.MovieClip;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import main.Vector_h;

    dynamic public class Laser extends MovieClip
    {
        var currentAsteroid:BasicObject;

        // ссылка на турель и на астероид
        public function init(turret:TurretObject, asteroid:BasicObject)
        {
            var x2:Number, y2:Number;
            var v:Vector_h;
            currentAsteroid = asteroid; // запоминаем ссылку на астероид
            v = new Vector_h(asteroid.x - turret.x, asteroid.y - turret.y);
            // длина луча лазера равна расстоянию до цели
            width = v.magnitude();
            // поворачиваемся к цели
            rotation = v.getDirection();
            // позиция из центра турели
            x = turret.x;
            y = turret.y;
            // создаем яркое свечение вокруг луча
            var myFilters:Array = [];
            myFilters.push(new GlowFilter(0xDFF4FD, 0.9));
            filters = myFilters;
            // "засветим" цель белым
            currentAsteroid.transform.colorTransform = new ColorTransform(1,1,1, 1, 100,100,100, 0);
        }

        // Самоудалиться. Вызов этой функции прописан в последнем кадре
        public function remove():void
        {
            // вернем естественный цвет астероиду
            currentAsteroid.transform.colorTransform = new ColorTransform(1,1,1, 1, 0,0,0, 0);
            if (parent){ parent.removeChild(this) }
        }
    }
}
