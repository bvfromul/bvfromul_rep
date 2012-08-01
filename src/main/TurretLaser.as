// лазерная турель
package main
{
    import main.TurretObject;

    dynamic public class TurretLaser extends TurretObject
    {
        public function TurretLaser()
        {
            turret_type = 1; // тип турели - лазерная
            trgt_radius = 200; // радиус поражения целей 2 сектора
            hp=maxHP=50; // уровень жизни маленький
            max_weapon_recharge=21; // время перезаряда пушки - одна секунда (21 кадр)
        }

        // Выстрел по цели trgt
        override public function fire():void
        {
            // создаем лазерный луч до цели
            var ls:Laser = new Laser();
            ls.init(this, trgt);
            // добавляем на главный мувик sky _под_ всеми объектами
            parent.addChildAt(ls, 2);
            // снимаем HP у цели
            trgt.hp -= 20;
            // запустить процесс перезарядки пушки
            weapon_recharge = 0;
        }

        // Масса лазерной турели небольшая
        override public function getMassa():Number
        {
            return 100;
        }

        public function remove():void
        {
            if (parent)
            {
                parent.removeChild(this);
            }
        }
    }
}
