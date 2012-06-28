package main
{
    import main.*;

    dynamic public class Static_object extends Basic_object
    {
        public function Static_object()
        {
            // вычислим наш радиус, основываясь на размере картинки
            radius = Math.floor((width+height)/4);
        }
    }
}
