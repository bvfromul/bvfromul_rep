// регулятор громкости звуков
package main {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.media.SoundTransform;
    import flash.media.SoundChannel;

    dynamic public class Volume extends Sprite
    {
        static var volume:Number = 0.7;	// громкость звуков
        var oldVolume:Number;           // громкость звуков до выключения
        public var bgSnd:SoundChannel;	// фоновая музыка

        public function Volume()
        {
            // клик по фоновой полоске
            this.bg.addEventListener(MouseEvent.CLICK, handleBgClick);
            // клик по изображению динамика
            this.off.addEventListener(MouseEvent.CLICK, handleOffClick);
            this.off.buttonMode=true;
            // для перетаскивания ползунка перехватываем нажатие и отпускание кнопки мышки
            this.track.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
            this.track.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
            this.track.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);

            // включим фоновую музыку
            var sound = new Spacewind();
            bgSnd = sound.play(0, 100000000); // повторять много-много раз

            // Установим ползунок
            setVolume(volume);
        }

        // Установить громкость
        public function setVolume(newVolume:Number):void
        {
            volume=newVolume;
            this.track.x = volume*100; // предвигаем ползунок
            // изменим громкость фоновой музыки
            bgSnd.soundTransform = new SoundTransform(volume);
        }

        // клик по фоновой полоске
        function handleBgClick(event:Event):void
        {
            setVolume(this.bg.mouseX/100);
        }

        // клик по изображению динамика
        function handleOffClick(event:Event):void
        {
            if (this.off.currentFrame == 1)
            {
                // выключаем звук
                // запомним текущую громкость
                oldVolume = volume;
                // уберем ползунок
                this.track.visible=false;
                setVolume(0);
                // переходим на кадр, где перечеркнутый динамик
                this.off.gotoAndStop(2);
            }
            else
            {
                // восстанавливаем звук
                setVolume(oldVolume);
                // восстановим ползунок
                this.track.visible=true;
                // переходим на кадр, где нормальный динамик
                this.off.gotoAndStop(1);
            }
        }

        // начало перетаскивания ползунка
        function handleMouseDown(event:Event):void
        {
            var rectangle:Rectangle = new Rectangle(0,0, 100,0);
            // начнем перетаскивание
            this.track.startDrag(true, rectangle);
        }

        // при перемещении ползунка меняем громкость
        function handleMouseMove(event:Event):void
        {
            setVolume(this.track.x/100);
        }

        // окончание перетаскивания ползунка
        function handleMouseUp(event:Event):void
        {
            // прекратили перетаскивание
            this.track.stopDrag();
        }

    }
}
