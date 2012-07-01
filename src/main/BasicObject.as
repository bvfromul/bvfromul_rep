package main
{
    import flash.display.MovieClip;

    dynamic public class BasicObject extends MovieClip
    {
        public var radius:Number; // радиус

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
    }
}
