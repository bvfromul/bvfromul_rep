package main
{
    public class vector_h
    {
        public var x:Number;
        public var y:Number;

        public function vector_h(setX:Number = 0, setY:Number = 0)
        {
            x = setX;
            y = setY;
        }

        function copyVector( v:Vector ):void
        {
            x = v.x;
            y = v.y;
        }

        public function setMembers( x1:Number, y1:Number ):void
        {
            x = x1;
            y = y1;
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
