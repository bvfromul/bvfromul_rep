package main
{
    import flash.display.MovieClip;
    import flash.events.*;
    import main.*;

    dynamic public class Sky extends MovieClip
    {
        var MIN_DROP:Number, MAX_DROP:Number; // пределы количества вбрасываемых астероидов
        var all_moving:Array; // здесь все движущиеся объекты

        public function Sky()
        {
            all_moving = new Array();
            // сколько астероидов вбрасывается
            // это не константы, т.к. со временем количество астероидов должно увеличиваться
            MIN_DROP=5; MAX_DROP=10;

            addEventListener(Event.ENTER_FRAME, Update);
            // тестовый вброс
            DropSeveralAsteroids();
        }

        public function DropSeveralAsteroids():void
        {
            var x1:Number, y1:Number; // точка вброса
            var x2:Number, y2:Number; // куда двигаться
            var cnt:Number;    // количество вбрасываемых встероидов
            var new_asteroid:Moving_object; // объект астероида

            x1=0; y1=0; // пока так, для теста, из левого верхнего угла
            x2=this.earth.x; y2=this.earth.y; // двигаться к земле
            // выбираем рандомное количество
            cnt = MIN_DROP + Math.floor((MAX_DROP-MIN_DROP)*Math.random());
            while (cnt--)
            {
                new_asteroid = new Moving_object();     // создаем новый астероид
                addChild(new_asteroid);           // добавляем его на наш мувиклип
                all_moving.push(new_asteroid);    // запоминаем в массиве
                new_asteroid.drop(x1,y1, x2,y2);  // бросаем
            }
        }

        public function Update(e : Event):void
        {
            // Проходим по всему массиву созданных объектов
            // и заставляем каждого сдвинуться в своем направлении
            for each (var obj:Moving_object in all_moving)
            {
                obj.move();
            }
        }
    }
}
