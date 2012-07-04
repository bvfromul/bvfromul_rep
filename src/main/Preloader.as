package main
{
    import flash.display.MovieClip;
    import flash.events.Event;

    dynamic public class Preloader extends MovieClip
    {
        public function Preloader()
        {
            // Нужно периодически вызывать Update, которая будет обновлять процент загрузки
            // Используем старый-добрый onEnterFrame с учетом событий AS3
            addEventListener(Event.ENTER_FRAME, update);
        }

        public function update(event : Event):void
        {
            var bytesLoaded:Number = stage.loaderInfo.bytesLoaded;
            var bytesTotal:Number = stage.loaderInfo.bytesTotal;
            var status:String = "";
            var percent:Number = 0;

            if (bytesTotal > 0)
            {
                percent = Math.floor(bytesLoaded/bytesTotal*100);
                status = percent+"% ("+
                Math.round(bytesLoaded/1024)+"кб / "+
                Math.round(bytesTotal/1024)+"кб)";
            }

            this.txt.text="Загрузка... "+status;
            this.progressbar.gotoAndStop(percent + 1);

            // Если полностью загрузились, то переходим на второй кадр
            if (bytesLoaded == bytesTotal || bytesTotal == 0)
            {
                removeEventListener(Event.ENTER_FRAME, update);
                (this.parent as MovieClip).play();
            }
        }
    }
}
