package main{
import flash.display.MovieClip;
import flash.events.*;
import main.Vector_h;
import main.Ball;

dynamic public class BallCollision extends MovieClip {

    function BallCollision()
    {
        // Проверяем не столкнулись ли какие шарики
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    function onEnterFrame(e : Event):void
    {
        var cnt:Number = 9; // количество шаров
        var mc1:MovieClip, mc2:MovieClip;
        var i:Number, j:Number;
        for (i=1; i<=cnt; i++) {
            mc1=this["b"+i];
            for (j=i+1; j<=cnt; j++) {
                mc2=this["b"+j];
                if (mc1.CheckCollision(mc2)) {
                    trace("Boom "+i+" vs "+j);
                    resolve(mc1, mc2);
                }
            }
        }
        // Подсчитаем и выведем общую кинетическую энергию шаров
        var Ek:Number=0;
        for (i=1; i<=cnt; i++) {
            mc1=this["b"+i];
            Ek += mc1.getMassa() / 2*mc1.Velocity.magnitude2();
        }
        this.txt.text="Кинетическая энергия всех шаров = "+Math.floor(Ek);
    }

    function resolve(ball1:Ball, ball2:Ball):void
    {
        var b1Velocity:Vector = ball1.Velocity;
        var b2Velocity:Vector = ball2.Velocity;
        var b1Mass:Number     = ball1.getMassa();
        var b2Mass:Number     = ball2.getMassa();

        // Отодвинем легкий шарик назад, чтобы не пересекались
        if (b1Mass<b2Mass) PullBalls(ball1, ball2);
        else PullBalls(ball2, ball1);

        var lineOfSight:Vector = new Vector(ball1.x-ball2.x, ball1.y-ball2.y);
        var v1Prime:Vector = b1Velocity.vectorProjectionOnto(lineOfSight);
        var v2Prime:Vector = b2Velocity.vectorProjectionOnto(lineOfSight);

        var v1Prime2:Vector = new Vector();
        v1Prime2.copyVector(v2Prime);
        v1Prime2.mulScalar(2*b2Mass);
        v1Prime2.addVector(v1Prime.getMulScalar(b1Mass - b2Mass));
        v1Prime2.mulScalar(1.0/(b1Mass + b2Mass));

        var v2Prime2:Vector = new Vector();
        v2Prime2.copyVector(v1Prime);
        v2Prime2.mulScalar(2*b1Mass);
        v2Prime2.subVector(v2Prime.getMulScalar(b1Mass - b2Mass));
        v2Prime2.mulScalar(1.0/(b1Mass + b2Mass));

        v1Prime2.subVector(v1Prime);
        v2Prime2.subVector(v2Prime);

        b1Velocity.addVector(v1Prime2);
        b2Velocity.addVector(v2Prime2);
    }

    // Отодвигает шарик 1 от шарика 2, чтобы они не пересекались
    function PullBalls(ball1:Ball, ball2:Ball):void
    {
        var v:Vector = new Vector(ball1.x-ball2.x, ball1.y-ball2.y);
        var distance:Number = v.magnitude();
        var min_distance:Number = ball1.radius + ball2.radius;
        if (distance > min_distance) return; // не пересекаются
        v.mulScalar((0.1+min_distance-distance)/distance);
        ball1.x += v.x;
        ball1.y += v.y;
    }

}}
