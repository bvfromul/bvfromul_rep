package main
{
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import main.Sky;

    dynamic public class Minimap extends Sprite
    {
        var sky_mc:Sky;  // ссылка на главный класс
        var xscale:Number, yscale:Number; // масштаб карты
        var bg:Sprite;   // здесь все рисуем

        public function Minimap(sky:Sky)
        {
            sky_mc = sky;
            // вычислим масштаб
            xscale = width/sky_mc.sky.width;
            yscale = height/sky_mc.sky.height;
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
            bg.graphics.drawRect((-sky_mc.x+50)*xscale, (-sky_mc.y+20)*yscale, (stage.stageWidth-50)*xscale, (stage.stageHeight-20)*yscale);
            // рисуем все объекты
            bg.graphics.lineStyle(0);

            for each (obj in sky_mc.allMoving)
            {
                // рисуем объект если он находится внутри игровой зоны
                if (obj.x > -Math.round((sky_mc.sky.width)/2) && obj.y > -Math.round(sky_mc.sky.height/2) && obj.x < Math.round((sky_mc.sky.width)/2) && obj.y < Math.round(sky_mc.sky.height/2))
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
            var min_x:Number = stage.stageWidth-sky_mc.sky.width;
            var min_y:Number = stage.stageHeight-sky_mc.sky.height;
            // максимально возможные у нас 0:0
            // Высчитываем, какие должны быть координаты игрового поля чтобы точка клика мышки
            // находилась точно в центре основного экрана
            //Math.min(0, Math.max(min_x, stage.stageWidth / 2 - mouseX / xscale))
            // Math.min(0, Math.max(min_y, stage.stageHeight/2-mouseY/yscale))
            sky_mc.x = Math.min(Math.round((sky_mc.sky.width)/2), Math.max(stage.stageWidth-Math.round((sky_mc.sky.width) / 2), stage.stageWidth/2-mouseX/xscale));
            sky_mc.y = Math.min(Math.round(sky_mc.sky.height/2), Math.max(stage.stageHeight-Math.round(sky_mc.sky.height/2), stage.stageHeight/2-mouseY/yscale));
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
