// ракетная турель
package main {
    import main.TurretObject;

    dynamic public class TurretRocket extends TurretObject
    {
        private var turretRocketRadius:Number = GameConst.turretRocketRadius;
        private var turretRocketHp:Number = GameConst.turretRocketHp;
        private var turretRocketRecharge:Number = GameConst.turretRocketRecharge;
        private var turretRocketCost:Number = GameConst.turretRocketCost;
        private var turretRocketMassa:Number = GameConst.turretRocketMassa;

        public function TurretRocket():void
        {
            turretType = 2;                            // тип турели - ракетная
            trgtRadius = turretRocketRadius;           // радиус поражения большой - целей 3.3 сектора
            hp = maxHP = turretRocketHp;               // уровень жизни совсем маленький
            maxWeaponRecharge=turretRocketRecharge;    // время перезаряда пушки - 3 секунды
            cost = turretRocketCost;                   // сколько стоит поставить эту турель
            findBigObjects = true;                     // приоритенее "толстые" объекты
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
            weaponRecharge = 0;
            // звук выстрела
            (parent as Sky).panel.PlaySnd('launch_rocket', this);
        }

        // Масса в 2 раза больше, чем у лазерной турели
        override public function getMassa():Number
        {
            return turretRocketMassa;
        }
    }
}
