package main
{
    public class Vector_h
    {
        public var x:Number;
        public var y:Number;

        public function Vector_h(setX:Number = 0, setY:Number = 0)
        {
            x = setX;
            y = setY;
        }

        function copyVector( v:Vector_h ):void
        {
            x = v.x;
            y = v.y;
        }

        public function setMembers( x1:Number, y1:Number ):void
        {
            x = x1;
            y = y1;
        }

        function addVector( v:Vector_h ):void
        {
            x += v.x;
            y += v.y;
        }

        function subVector( v:Vector_h ):void
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

        // returns the Vector_h projection of this Vector_h onto v
        function vectorProjectionOnto(v:Vector_h):Vector_h
        {
            var res:Vector_h = v.getUnitVector();
            res.mulScalar(scalarProjectionOnto(v));
            return res;
        }

        function getUnitVector():Vector_h
        {
            var len:Number = magnitude();
            var res:Vector_h = new Vector_h(x,y);
            if (len)
            {
                res.x /= len;
                res.y /= len;
            }
            return res;
        }

        // returns the scalar projection of this Vector_h onto v
        function scalarProjectionOnto(v:Vector_h):Number
        {
            return (x*v.x + y*v.y)/v.magnitude();
        }

        function getMulScalar( i:Number ):Vector_h {
            return new Vector_h(x*i, y*i);
        }

        // угол в градусах
        function getDirection():Number
        {
            return Math.atan2(y, x)/Math.PI*180;
        }
    }
}
