package main {

    public class GameConst
    {
        static const startMoney:Number = 1000;           // сколько монет выдается в начале игры

        static const hideTimeout:Number = 1000;          // время скрытия полоски жизни (1000 - 1с)

        static const dropRadius:Number = 200;            // разброс при вбрасывании

        static const minSpeed:Number = 1;                // раброс начальной скорости движущегося объекта
        static const maxSpeed:Number = 10;               // раброс начальной скорости движущегося объекта

        static const rocketMaxSpeed:Number = 12;         // максимальная скорость
        static const rocketDamage:Number = 300;          // наносимый урон цели ракетой
        static const rocketExplosnPower:Number = 200;    // сила ударной волны при взрыве ракеты

        static const asteroindFirstDrop:Number = 2;      // cколько астероидов вбрасывается вначале
        static const asteroidIncSpeedDrop:Number = 0.2;  // скорость увеличения количества астероидов
        static const asteroidCntMinDrop:Number = 1;      // пределы количества вбрасываемых астероидов
        static const asteroidCntMaxDrop:Number = 7;      // пределы количества вбрасываемых астероидов
        static const asteroidSpallMinSpeed:Number = 3;   // разброс начальной скорости осколков астероида
        static const asteroidSpallMaxSpeed:Number = 10;  // разброс начальной скорости осколков астероида

        static const turretBastionHp:Number = 500;       // количество HP у туррели-крепости
        static const turretBastionCost:Number = 100;     // стоимость туррели-крепости
        static const turretBastionMassa:Number = 1000;   // масса туррели-крепости

        static const turretLaserRadius:Number = 200;     // радиус поражения
        static const turretLaserHp:Number = 15;          // количество HP
        static const turretLaserRecharge:Number = 10;    // скорость перезарядки пушки
        static const turretLaserCost:Number = 25;        // стоимость
        static const turretLaserMassa:Number = 100;      // масса
        static const turretLaserDamage:Number = 20;      // наносимый урон

        static const turretRocketRadius:Number = 330;    // радиус поражения
        static const turretRocketHp:Number = 25;         // количество HP
        static const turretRocketRecharge:Number = 63;   // скорость перезарядки пушки
        static const turretRocketCost:Number = 40;       // стоимость
        static const turretRocketMassa:Number = 200;     // масса
    }
}
