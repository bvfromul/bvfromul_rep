// ракетная турель
package main {
    import main.TurretObject;

    dynamic public class TurretRocket extends TurretObject
    {
        const TURRET_RADIUS:Number = 330;   // радиус поражения
        const TURRET_HP:Number = 25;        // количество HP
        const TURRET_RECHARGE:Number = 63;  // скорость перезарядки пушки
        const TURRET_COST:Number = 40;      // стоимость
        const TURRET_MASS:Number = 200;     // масса

        public function TurretRocket()
        {
            turret_type = 2;                        // тип турели - ракетная
            trgt_radius = TURRET_RADIUS;            // радиус поражения большой - целей 3.3 сектора
            hp = maxHP = TURRET_HP;                 // уровень жизни совсем маленький
            max_weapon_recharge=TURRET_RECHARGE;    // время перезаряда пушки - 3 секунды
            //cost = TURRET_COST;                     // сколько стоит поставить эту турель
            findBigObjects = true;                  // приоритенее "толстые" объекты
        }

        // Выстрел по цели trgt
        override public function fire():void
        {
            // создаем ракету
            var rocket:Rocket = new Rocket();
            (parent as Sky).addChild(rocket); // добавляем на главный мувик sky
            rocket.init(this, trgt);
            (parent as Sky).addObjectInSectors(rocket);   // добавляем в сектора
            // запустить процесс перезарядки пушки
            weapon_recharge = 0;
            // звук выстрела
            //root.panel.PlaySnd('launch_rocket', this);
        }

        // Масса в 2 раза больше, чем у лазерной турели
        override public function getMassa():Number
        {
            return TURRET_MASS;
        }
    }
}