// лазерная турель
package main
{
    import main.TurretObject;

    dynamic public class TurretLaser extends TurretObject
    {
        const TURRET_RADIUS:Number = 200;   // радиус поражения
        const TURRET_HP:Number = 10;        // количество HP
        const TURRET_RECHARGE:Number = 10;  // скорость перезарядки пушки
        const TURRET_COST:Number = 20;      // стоимость
        const TURRET_MASS:Number = 100;     // масса
        const TURRET_DAMAGE:Number = 20;    // наносимый урон

        public function TurretLaser()
        {
            turretType = 1; // тип турели - лазерная
            trgt_radius = TURRET_RADIUS; // радиус поражения целей 2 сектора
            hp=maxHP=TURRET_HP; // уровень жизни маленький
            max_weapon_recharge = TURRET_RECHARGE; // время перезаряда пушки
            cost = TURRET_COST;	// сколько стоит поставить эту турель
        }

        // Выстрел по цели trgt
        override public function fire():void
        {
            // создаем лазерный луч до цели
            var laser:Laser = new Laser();
            laser.init(this, trgt);
            // добавляем на главный мувик sky _под_ всеми объектами
            parent.addChild(laser);
            // снимаем HP у цели
            trgt.hp -= TURRET_DAMAGE;
            // запустить процесс перезарядки пушки
            weapon_recharge = 0;
            (parent as Sky).panel.PlaySnd('lasersound', this);
        }

        // Масса лазерной турели небольшая
        override public function getMassa():Number
        {
            return TURRET_MASS;
        }
    }
}
