// турель-крепость
package main {
    import flash.filters.GlowFilter;

    dynamic public class TurretBastion extends TurretObject
    {
        const TURRET_HP:Number = 80;    // количество HP
        const TURRET_COST:Number = 70;    // стоимость
        const TURRET_MASS:Number = 900;// масса
        var phosphorescence:Number;    // пульсация свечения
        var my_filter:Array;        // само свечение

        public function TurretBastion()
        {
            turret_type = 3;    // тип турели - крепость
            trgt_radius = 0;    // не имеет радиуса поражения
            hp = maxHP = TURRET_HP;    // уровень жизни
            //cost = TURRET_COST;    // сколько стоит поставить эту турель
            phosphorescence = 0.02;    // скорость изменения свечения
            velocitySlowdown = 0.8;    // коэф. торможения
            // случайно повернем фоновую картинку
            this.bg2.rotation=(Math.random()-0.5)*360;
            // создаем свечение
            my_filter = [];
            my_filter.push(new GlowFilter(0x4099E3, 0.8, 10,10));
        }

        // Масса большая
        override public function getMassa():Number
        {
            return TURRET_MASS;
        }

        // Добавим изменение свечения защитного экрана
        override public function move():void
        {
            var al:Number = my_filter[0].alpha; // текущая прозрачность свечения
            if (al+phosphorescence>1 || al+phosphorescence<0.5){ // выходим за границы
                phosphorescence *= -1;    // меняем направление изменения прозрачности
            }
            // меняем интенсивность свечения
            my_filter[0].alpha = al+phosphorescence;
            this.bg.filters = my_filter;
            // вызываем базовую функцию move
            super.move();
        }
    }
}
