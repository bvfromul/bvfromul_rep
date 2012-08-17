package main {
    import flash.display.Sprite;
    import flash.filters.GlowFilter;
    import flash.events.Event;
    import flash.display.MovieClip;

    dynamic public class GameOver extends Sprite
    {
        var bg:Sprite;

        public function init(sky:Sky)
        {
            var dx:Number = stage.stageWidth/2;
            var dy:Number = stage.stageHeight/2;
            // размещаемся в центре экрана
            x = dx;
            y = dy;
            // отобразим набранные очки
         //   this.score_label.text = "Score: "+Math.floor(sky.panel.score);
            // создаем яркое свечение вокруг текста
          //  var myFilters:Array = {};
          //  myFilters.push(new GlowFilter(0xDFF4FD, 0.5, 40,40));
          //  this.title.filters = myFilters;
            //this.score_label.filters = myFilters;
            // создадим Sprite под текстом
           // bg = new Sprite();
         //   addChildAt(bg, 0);
            // рисуем на нем черный прямоугольник размером с экран
          // bg.graphics.beginFill(0);
            //bg.graphics.drawRect(-dx,-dy, dx*2,dy*2);
           // bg.graphics.endFill();
            // ставим полную прозрачность
            //bg.alpha=0;
            // по ENTER_FRAME будем уменьшать прозрачность
            //var handlerEnterFrame:Function = function(event:Event):void { update(sky); };
           // addEventListener(Event.ENTER_FRAME, handlerEnterFrame);
            sky.panel.minimap.removeEventListener(Event.ENTER_FRAME, update);
            sky.panel.parent.removeChild(sky.panel);
            // прекращаем перетаскивание объектов
            //sky.bg.handleMouseLeave();
        }

        function update(sky:Sky):void
        {
            // уменьшаем прозрачность
            bg.alpha+=0.007;
            if (bg.alpha >= 1)
            {
                // если экран полностью затемнился
                sky.done();    // у sky вызываем удаление всех объектов
                MovieClip(root).gotoAndStop(2);    // переходим на второй кард флешки
                removeEventListener(Event.ENTER_FRAME, update); // удаляем обработку события
                parent.removeChild(this);   // удаляем себя
            }
        }
    }
}