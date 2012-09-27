package main
{
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import main.Sky;

    dynamic public class Minimap extends Sprite
    {
        private var parentClass:Sky;           // ссылка на главный класс
        var xscale:Number, yscale:Number;      // масштаб карты
        var bg:Sprite;                         // здесь все рисуем

        public function Minimap(sky:Sky)
        {
            parentClass = sky;
            // вычислим масштаб
            xscale = width/parentClass.sky.width;
            yscale = height/parentClass.sky.height;
            // Создаем слой на котором будем все рисовать
            bg = new Sprite;
            addChild(bg);
            // Перехватываем нажатие кнопки мыши по нашему мувику
            addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
            // и передвижение мышки
            addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
            // Обновляем изображение на миникарте по onEnterFrame
            addEventListener(Event.ENTER_FRAME, update);
        }

        // обновить изображение
        public function update(event:Event = undefined):void
        {
            var obj:BasicObject;
            bg.graphics.clear(); // очищаем
            // рисуем рамку, текущего обзора, толщина линии 1, цвет белый, 50% прозрачность
            bg.graphics.lineStyle(1, 0xFFFFFF, 0.5);
            bg.graphics.drawRect((-parentClass.x+50)*xscale, (-parentClass.y+20)*yscale, (stage.stageWidth-50)*xscale, (stage.stageHeight-20)*yscale);
            // рисуем все объекты
            bg.graphics.lineStyle(0);

            for each (obj in parentClass.allMoving)
            {
                // рисуем объект если он находится внутри игровой зоны
                if (obj.x > -Math.round((parentClass.sky.width)/2) && obj.y > -Math.round(parentClass.sky.height/2) && obj.x < Math.round((parentClass.sky.width)/2) && obj.y < Math.round(parentClass.sky.height/2))
                {
                    bg.graphics.beginFill(obj.type==1?0xFF0000:(obj.type==2?0x0000FF:0xFFFF00));
                    bg.graphics.drawCircle(obj.x*xscale, obj.y*yscale,
                    Math.max(1, obj.radius*(xscale+yscale)/2));
                    bg.graphics.endFill();
                }
            }
        }

        // Нажатие кнопки мыши
        function handleMouseDown(event:Event):void
        {
            // вычислим минимально возможные координаты игрового поля
            var minX:Number = stage.stageWidth-parentClass.sky.width;
            var minY:Number = stage.stageHeight-parentClass.sky.height;
            // максимально возможные у нас 0:0
            // Высчитываем, какие должны быть координаты игрового поля чтобы точка клика мышки
            // находилась точно в центре основного экрана
            parentClass.x = Math.min(Math.round((parentClass.sky.width)/2), Math.max(stage.stageWidth-Math.round((parentClass.sky.width) / 2), stage.stageWidth/2-mouseX/xscale));
            parentClass.y = Math.min(Math.round(parentClass.sky.height/2), Math.max(stage.stageHeight-Math.round(parentClass.sky.height/2), stage.stageHeight/2-mouseY/yscale));
        }

        // Перемещение мышки
        function handleMouseMove(event:MouseEvent):void
        {
            // если передвигают мышку по миникарте с зажатой кнопкой,
            // то двигать карту вслед за мышкой
            if (event.buttonDown)
            {
                handleMouseDown(event);
            }
        }
    }
}
