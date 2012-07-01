package main {

    import flash.display.MovieClip;

    public class Vector
    {
        var x:Number;
        var y:Number;

        public function Vector(setX:Number = 0, setY:Number = 0)
        {
            x = setX;
            y = setY;
        }

        function copyVector( v:Vector ):void
        {
            x = v.x;
            y = v.y;
        }

        function setMembers( x:Number, y:Number ):void
        {
            x = x;
            y = y;
        }

        function addVector( v:Vector ):void
        {
            x += v.x;
            y += v.y;
        }

        function subVector( v:Vector ):void
        {
            x -= v.x;
            y -= v.y;
        }

        function mulScalar( i:Number ):void
        {
            x *= i;
            y *= i;
        }

        function magnitude():Number
        {
            return Math.sqrt( x*x + y*y );
        }

        function magnitude2():Number
        {
            return x*x + y*y;
        }
    }
}
