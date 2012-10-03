// турель-крепость
package main {
    import flash.filters.GlowFilter;

    dynamic public class TurretBastion extends TurretObject
    {
        internal var phosphorescence:Number;    // пульсация свечения
        internal var glowFilter:Array;          // само свечение

        private var turretBastionHp:Number = GameConst.turretBastionHp;
        private var turretBastionCost:Number = GameConst.turretBastionCost;
        private var turretBastionMassa:Number = GameConst.turretBastionMassa;

        public function TurretBastion()
        {
            turretType = 3;    // тип турели - крепость
            trgtRadius = 0;    // не имеет радиуса поражения
            hp = maxHP = turretBastionHp;
            cost = turretBastionCost;
            phosphorescence = 0.02;    // скорость изменения свечения
            velocitySlowdown = 0.8;    // коэф. торможения
            // случайно повернем фоновую картинку
            this.bg2.rotation=(Math.random()-0.5)*360;
            // создаем свечение
            glowFilter = [];
            glowFilter.push(new GlowFilter(0x4099E3, 0.8, 10,10));
        }

        // Масса большая
        override public function getMassa():Number
        {
            return turretBastionMassa;
        }

        // Добавим изменение свечения защитного экрана
        override public function move():void
        {
            var al:Number = glowFilter[0].alpha; // текущая прозрачность свечения
            if (al + phosphorescence > 1 || al + phosphorescence < 0.5)
            {
                // выходим за границы
                phosphorescence *= -1;    // меняем направление изменения прозрачности
            }
            // меняем интенсивность свечения
            glowFilter[0].alpha = al+phosphorescence;
            this.bg.filters = glowFilter;
            // вызываем базовую функцию move
            super.move();
        }
    }
}
