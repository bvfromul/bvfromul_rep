package main
{
    dynamic public class StaticObject extends BasicObject
    {
        public function StaticObject()
        {
            // вычислим наш радиус, основываясь на размере картинки
            radius = Math.floor((width+height)/4);
        }
    }
}
