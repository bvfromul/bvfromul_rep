package main {
    import flash.display.Sprite;
    import flash.filters.GlowFilter;
    import flash.events.Event;
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.text.TextFormat;

    dynamic public class GameOver extends Sprite
    {
        var bg:Sprite;
        private var parentClass:Sky;

        public function set _parentClass(sky:Sky):void
        {
            parentClass = sky;
        }

        public function init()
        {
            var scoreLabel:TextField = new TextField;
            var tFormat:TextFormat = new TextFormat();

            var dx:Number = stage.stageWidth/2;
            var dy:Number = stage.stageHeight/2;
            // размещаемся в центре экрана
            x = dx;
            y = dy;
            // отобразим набранные очки

            scoreLabel.text = "Score: "+Math.floor(parentClass.panel.score).toString();
            scoreLabel.height = 59;
            scoreLabel.width = 411;
            scoreLabel.x = -209;
            scoreLabel.y = 29;
            tFormat.size = 50;
            tFormat.bold = true;
            tFormat.font = "Arial";
            tFormat.color = 0xFF0000;
            scoreLabel.setTextFormat(tFormat);
            addChild(scoreLabel);

            //trace(this.scoreLabel.text);
            // создаем яркое свечение вокруг текста
            var myFilters:Array = [];
            myFilters.push(new GlowFilter(0xDFF4FD, 0.5, 40,40));
            this.title.filters = myFilters;
            scoreLabel.filters = myFilters;
            // создадим Sprite под текстом
            bg = new Sprite();
            addChildAt(bg, 0);
            // рисуем на нем черный прямоугольник размером с экран
            bg.graphics.beginFill(0);
            bg.graphics.drawRect(-dx,-dy, dx*2,dy*2);
            bg.graphics.endFill();
            // ставим полную прозрачность
            bg.alpha=0;
            // по ENTER_FRAME будем уменьшать прозрачность
            addEventListener(Event.ENTER_FRAME, update);

            parentClass.removeEventListener(Event.ENTER_FRAME, parentClass.update);
            parentClass.panel.minimap.removeEventListener(Event.ENTER_FRAME, parentClass.panel.minimap.update);
            parentClass.panel.parent.removeChild(parentClass.panel);
            // прекращаем перетаскивание объектов
            //parentClass.bg.handleMouseLeave();
        }

        function update(event:Event):void
        {
            // уменьшаем прозрачность
            bg.alpha += 0.007;
            if (bg.alpha >= 1)
            {
                // если экран полностью затемнился
                parentClass.done();    // у sky вызываем удаление всех объектов
                MovieClip(root).gotoAndStop(2);    // переходим на второй кард флешки
                removeEventListener(Event.ENTER_FRAME, update); // удаляем обработку события
                parent.removeChild(this);   // удаляем себя
            }
        }
    }
}
