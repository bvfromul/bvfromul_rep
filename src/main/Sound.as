package main {
    import flash.media.SoundTransform;

    dynamic public class Sound extends Object
    {
        var snd:Object; // хэш со звуками
        var stageRadius:Number; // примерный радиус видимой области

        public function init(stageWidth:Number, stageHeight:Number)
        {
            // создадим все звуки
            snd = {};
            snd['asteroid_explosion'] = new asteroid_explosion();
            snd['asteroids_clash'] = new asteroids_clash();
            snd['EarthCrash'] = new EarthCrash();
            snd['explode_rocket'] = new explode_rocket();
            snd['explode_to_earth'] = new explode_to_earth();
            snd['lasersound'] = new lasersound();
            snd['launch_rocket'] = new launch_rocket();
            snd['error'] = new error();
            snd['addship'] = new addship();
            // вычислим примерный радиус (в квадрате) видимой области экрана
            stageRadius = Math.pow((stageWidth+stageHeight)/4, 2);
        }

        // Воспроизводит звук с учетом пространства
        // (dx,dy - смещение источника звука относительно центра экрана)
        // dv - множитель для громкости
        public function Play2DSnd(sndName:String, dx:Number, dy:Number):void
        {
            var soundTransfm:SoundTransform, vector:Vector_h;
            if (! Volume.volume)
            {
                return;// запрет звуков
            }
            vector = new Vector_h(dx, dy);
            soundTransfm = new SoundTransform();
            // Ставим громкость в зависимости от расстояния
            // Делаем так, чтобы громкость в углу экрана (stageRadius) была 50% от общей
            soundTransfm.volume = Volume.volume / (1 + vector.magnitude2()/stageRadius);
            // стерео в зависимости от угла до источника звука
            soundTransfm.pan = 1 - Math.abs(vector.getDirection())/90;
            // воспроизводим
            snd[sndName].play(0, 0, soundTransfm);
        }
    }
}
