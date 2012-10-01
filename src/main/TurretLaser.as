// лазерная турель
package main
{
    import main.TurretObject;

    dynamic public class TurretLaser extends TurretObject
    {
        private var turretLaserRadius:Number = GameConst.turretLaserRadius;
        private var turretLaserHp:Number = GameConst.turretLaserHp;
        private var turretLaserRecharge:Number = GameConst.turretLaserRecharge;
        private var turretLaserCost:Number = GameConst.turretLaserCost;
        private var turretLaserMassa:Number = GameConst.turretLaserMassa;
        private var turretLaserDamage:Number = GameConst.turretLaserDamage;

        public function TurretLaser()
        {
            turretType = 1; // тип турели - лазерная
            trgtRadius = turretLaserRadius; // радиус поражения целей 2 сектора
            hp=maxHP=turretLaserHp; // уровень жизни маленький
            maxWeaponRecharge = turretLaserRecharge; // время перезаряда пушки
            cost = turretLaserCost; // сколько стоит поставить эту турель
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
            trgt.hp -= turretLaserDamage;
            // запустить процесс перезарядки пушки
            weaponRecharge = 0;
            (parent as Sky).panel.PlaySnd('lasersound', this);
        }

        // Масса лазерной турели небольшая
        override public function getMassa():Number
        {
            return turretLaserMassa;
        }
    }
}
