// Ракета
package main {
    import main.BasicObject;

    dynamic public class Rocket extends BasicObject
    {
        private var maxSpeed:Number = GameConst.rocketMaxSpeed;
        private var damage:Number = GameConst.rocketDamage;
        private var trgt:BasicObject;       // цель
        private var selfDestruction:Number; // счетчик на самоуничтожение
        private var speed:Number;           // текущая скорость

        // ссылка на турель и на астероид
        public function init(turret:TurretObject, asteroid:BasicObject)
        {
            type='rocket'; // тип "ракета"
            // вычислим наш радиус, основываясь на размере картинки
            radius = Math.floor((width+height-4)/4);
            // добавляем себя рядом с турелью
            velocity.setMembers(asteroid.x-turret.x, asteroid.y-turret.y);
            velocity.mulScalar( (turret.radius+radius) / velocity.magnitude() );
            x = turret.x + velocity.x;
            y = turret.y + velocity.y;
            // запоминаем ссылку на астероид
            trgt = asteroid;
            // жизни практически нет, взрываемся от малейшего касания
            hp=maxHP=1;
            // начинаем разгон
            speed=1;
            // умираем через полторы секунды после потери цели
            selfDestruction=40;
            // сразу делаем "первый шаг", чтобы отлететь от турели
            // и не произошло столкновения с ней
            move();
        }

        // Переместиться
        override public function move():void
        {
            // набираем скорость
            if (speed < maxSpeed)
            {
                speed += Math.min(3, Math.max(0.3, 1/(maxSpeed-speed)));
            }
            if (!trgt || !trgt.hp)
            {
                // цель пропала или уничтожена, запускаем процесс самоуничтожения
                if (selfDestruction-- <= 0)
                {
                    // время вышло
                    hp = 0; // взрываемся
                }
                else
                {
                    // приведем вектор к текущей скорости
                    velocity.mulScalar( speed / velocity.magnitude() );
                }
            }
            else
            {
                // цель есть
                // вектор скорости у нас постоянно меняется
                // ракета летит за целью кратчайшим путем
                velocity.setMembers(trgt.x-x, trgt.y-y);
                // вычислим расстояние до цели
                var len:Number = velocity.magnitude();
                // приведем вектор к текущей скорости
                velocity.mulScalar( speed / len );
                // поворачиваемся к цели
                this.bg.rotation = velocity.getDirection();
                if (len <= trgt.radius + radius + speed)
                {
                    // подлетели вплотную, взрываемся
                    trgt.hp -= damage; // цели наносим серьезный дамаг
                    hp = 0;
                }
            }
            // летим
            x += velocity.x;
            y += velocity.y;
        }

        // Масса ракеты используется при расчете ударной волны при взрыве
        // поэтому ставим большую, словно взорвался большой астероид
        override public function getMassa():Number
        {
            return GameConst.rocketExplosnPower;
        }
    }
}
