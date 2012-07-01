package main {

    import flash.display.MovieClip;
    import main.*;

    dynamic public class Moving_object extends Basic_object
    {
        public var Velocity:Vector; // вектор движения

        public function Moving_object()
        {
            var num:Number;
            num = Math.floor(Math.random()*totalFrames)+1; // выбираем случайный кадр
            gotoAndStop(num); // и переходим на него
            Velocity = new Vector(); // создаем вектор
            // вычислим наш радиус, основываясь на размере картинки
            radius = Math.floor((width+height)/4);
        }
    }
}
