package gamestone.pathfinding {
	
   public class Grid {
   	
      private var _startNode:Node;
      private var _endNode:Node;
      private var _nodes:Array;
      private var _numCols:int;
      private var _numRows:int;
      private var _radius:int;
      
      public function Grid(){
      }
      
      public function initManualy(nodes:Array):void {
         _numCols = nodes.length;
         _numRows = nodes[0].length;
         _nodes = nodes;
      }
      
      public function initAutomatic(numCols:int, numRows:int):void {
         _numCols=numCols;
         _numRows=numRows;
         _nodes = new Array();

         for (var i:int = 0; i < _numCols; i++) {
            _nodes[i] = new Array();
            for (var j:int = 0; j < _numRows; j++) {
               _nodes[i][j]=new Node(i,j);
            }
         }
      }
      

      public function getNode(x:int, y:int):Node {
      	 if (x >= _numCols || x < 0 || y >= _numRows || y < 0)
      	 	return null;
         return _nodes[x][y] as Node;
      }

      public function setEndNode(x:int, y:int):void {
         _endNode=_nodes[x][y] as Node;
      }

      public function setStartNode(x:int, y:int):void {
         _startNode=_nodes[x][y] as Node;
      }
	  
	  public function setRadius(radius:int):void {
         _radius = radius;
      }
      
      public function setWalkable(x:int, y:int, value:Boolean):void {
         _nodes[x][y].walkable=value;
      }

      public function get endNode():Node {
         return _endNode;
      }

      public function get numCols():int {
         return _numCols;
      }

      public function get numRows():int {
         return _numRows;
      }

      public function get startNode():Node {
         return _startNode;
      }
	  
	  public function get radius():int {
         return _radius;
      }
   }
}