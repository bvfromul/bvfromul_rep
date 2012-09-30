package main {

    public class GameConst
    {
        static const startMoney:Number = 1000;           // сколько монет выдается в начале игры
        static const hideTimeout:Number = 1000;          // время скрытия полоски жизни (1000 - 1с)
        static const dropRadius:Number = 200;            // разброс при вбрасывании
        static const minSpeed:Number = 1;                // раброс начальной скорости движущегося объекта
        static const maxSpeed:Number = 10;               // раброс начальной скорости движущегося объекта
        static const rocketMaxSpeed:Number = 12          // максимальная скорость
        static const rocketDamage:Number = 300           // наносимый урон цели ракетой
        static const rocketExplosnPower:Number = 200     // сила ударной волны при взрыве ракеты
        static const asteroindFirstDrop:Number = 2       // cколько астероидов вбрасывается вначале
        static const asteroidIncSpeedDrop:Number = 0.2   // скорость увеличения количества астероидов
        static const asteroidCntMinDrop:Number = 1     // пределы количества вбрасываемых астероидов
        static const asteroidCntMaxDrop:Number = 7     // пределы количества вбрасываемых астероидов

    }
}
