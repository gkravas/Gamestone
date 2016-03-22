﻿package away3d.extrusions{   	import flash.display.BitmapData;	import flash.geom.Point;	import flash.geom.Matrix;	public class ElevationReader {				private var channel:String;		private var levelBmd:BitmapData;		private var elevate:Number;		private var scalingX:Number;		private var scalingY:Number;		private var buffer:Array;		private var level:Number;		private var offsetX:Number = 0;		private var offsetY:Number = 0;		private var smoothness:int;				private var _minElevation:Number = 0;		private var _maxElevation:Number = 255;				/**		* Locks elevation factor beneath this level. Default is 0;		*		*/		public function set minElevation(val:Number):void        {			_minElevation = val;		}		public function get minElevation():Number        {			return _minElevation;		}				/**		* Locks elevation factor above this level. Default is 255;		*		*/		public function set maxElevation(val:Number):void        {			_maxElevation = val;		}		public function get maxElevation():Number        {			return _maxElevation;		}				/**		* Class generates a traced representation of the elevation geometry, allowing surface tracking to place or move objects on the elevation geometry.  <ElevationReader ></code>		* 		*/		public function ElevationReader(smoothness:int = 0)        {			buildBuffer(smoothness);		}				private function buildBuffer(smoothness:int = 0):void		{			this.smoothness = smoothness;			buffer = [];			for(var i:int = 0;i<smoothness;++i){				buffer.push(0);			}			level = 0;		}				/**		 * Optional method to be allow the use of a custom (externally) prerendered map.		 * @param	sourceBmd		Bitmapdata. The bitmapData to read from.		* @param	channel			[optional] String. The channel information to read. Supported "a", alpha, "r", red, "g", green, "b", blue and "av" (averages and luminance). Default is red channel "r".		* @param	factorX			[optional] Number. The scale multiplier along the x axis. Default is 1.		* @param	factorY			[optional] Number. The scale multiplier along the y axis. Default is 1.		* @param	factorZ			[optional] Number. The scale multiplier along the z axis (the elevation factor). Default is .5.		 */		public function setSource(sourceBmd:BitmapData, channel:String = "r", factorX:Number = 1, factorY:Number = 1, factorZ:Number = .5):void        {			levelBmd = sourceBmd;			this.channel = channel;			scalingX = factorX;			scalingY = factorY;			elevate = factorZ;		}		/**		 * returns the generated bitmapdata, a smooth representation of the geometry.		 */		public function get source():BitmapData        {			return levelBmd;		}		/**		 * returns the generated bitmapdata, a smooth representation of the geometry.		 * 		 * @param	x				The x coordinate on the generated bitmapdata.		 * @param	y				The y coordinate on the generated bitmapdata.		 * @param	offset			[optional]	the offset that will be added to the elevation value at the x and y coordinates plus the offset. Default = 0. 		 *		 * @return 	A Number, the elevation value at the x and y coordinates plus the offset.		 */				public function getLevel(x:Number, y:Number, offset:Number = 0):Number        {			var col:Number = x/scalingX;			var row:Number = y/scalingY; 			col += (levelBmd.width*.5)+offsetX;			row += (levelBmd.height*.5)+offsetY;			var color:Number = levelBmd.getPixel(col, row);						var r:Number = color >> 16 & 0xFF;						if(maxElevation < r)				r = maxElevation;			if(minElevation > r)				r = minElevation;						if(smoothness == 0) return (r*elevate)+offset;						buffer.push((r*elevate)+offset);			buffer.shift();						level = 0;			for(var i:int = 0;i<buffer.length;++i){				level += buffer[i];			}						return level/buffer.length;		}				/**		 * generates the smooth representation of the geometry. uses same parameters as the Elevation class.		 * 		* @param	sourceBmd				Bitmapdata. The bitmapData to read from.		* @param	channel					[optional] String. The channel information to read. supported "a", alpha, "r", red, "g", green, "b", blue and "av" (averages and luminance). Default is red channel "r".		* @param	subdivisionX			[optional] int. The subdivision to read the pixels along the x axis. Default is 10.		* @param	subdivisionY			[optional] int. The subdivision to read the pixels along the y axis. Default is 10.		* @param	scalingX					[optional] Number. The scale multiplier along the x axis. Default is 1.		* @param	scalingY					[optional] Number. The scale multiplier along the y axis. Default is 1.		* @param	elevate					[optional] Number. The scale multiplier along the z axis. Default is .5.		* 		* @see away3d.extrusions.Elevation		*/				public function traceLevels(sourceBmd:BitmapData, channel:String = "r", subdivisionX:int = 10, subdivisionY:int = 10, factorX:Number = 1, factorY:Number = 1, elevate:Number = .5):void		{			setSource(sourceBmd.clone(), channel, factorX, factorY, elevate);			 			var w:Number = sourceBmd.width;			var h:Number = sourceBmd.height;			var i:int = 0;			var j:int = 0;			var k:int = 0;			var l:int = 0;						var px1:Number; 			var px2:Number;			var px3:Number;			var px4:Number;						var lockx:int;			var locky:int;			levelBmd.lock();						var incXL:Number;			var incXR:Number;			var incYL:Number;			var incYR:Number;			var pxx:Number;			var pxy:Number;						for(i = 0; i < w+1; i+=subdivisionX)			{								if(i+subdivisionX > w-1)				{					offsetX = (w-i-1)*.5;					lockx = w-1;				} else {					lockx = i+subdivisionX;				}				for(j = 0; j < h+1; j+=subdivisionY)				{					if(j+subdivisionY > h-1)					{						offsetY = (h-j-1)*.5;						locky = h-1;					} else {						locky = j+subdivisionY;					}					 					if(j == 0){						switch(channel){							case "a":								px1 = sourceBmd.getPixel32(i, j) >> 24 & 0xFF;								px2 = sourceBmd.getPixel32(lockx, j) >> 24 & 0xFF;								px3 = sourceBmd.getPixel32(lockx, locky) >> 24 & 0xFF;								px4 = sourceBmd.getPixel32(i, locky) >> 24 & 0xFF;								break;							case "r":								px1 = sourceBmd.getPixel(i, j) >> 16 & 0xFF;								px2 = sourceBmd.getPixel(lockx, j) >> 16 & 0xFF;								px3 = sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF;								px4 = sourceBmd.getPixel(i, locky) >> 16 & 0xFF;								break;							case "g":								px1 = sourceBmd.getPixel(i, j) >> 8 & 0xFF;								px2 = sourceBmd.getPixel(lockx, j) >> 8 & 0xFF;								px3 = sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF;								px4 = sourceBmd.getPixel(i, locky) >> 8 & 0xFF;								break;							case "b":								px1 = sourceBmd.getPixel(i, j) & 0xFF;								px2 = sourceBmd.getPixel(lockx, j) & 0xFF;								px3 = sourceBmd.getPixel(lockx, locky) & 0xFF;								px4 = sourceBmd.getPixel(i, locky) & 0xFF;								break;							case "av":								px1 = ((sourceBmd.getPixel(i, j) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(i, j) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(i, j) & 0xFF)*0.072169);								px2 = ((sourceBmd.getPixel(lockx, j) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(lockx, j) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(lockx, j) & 0xFF)*0.072169);								px3 = ((sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(lockx, locky) & 0xFF)*0.072169);								px4 = ((sourceBmd.getPixel(i, locky) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(i, locky) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(i, locky) & 0xFF)*0.072169);						}						 					} else {												px1 = px4;						px2 = px3;						switch(channel){							case "a":								px3 = sourceBmd.getPixel32(lockx, locky) >> 24 & 0xFF;								px4 = sourceBmd.getPixel32(i, locky) >> 24 & 0xFF;								break;							case "r":								px3 = sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF;								px4 = sourceBmd.getPixel(i, locky) >> 16 & 0xFF;								break;							case "g":								px3 = sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF;								px4 = sourceBmd.getPixel(i, locky) >> 8 & 0xFF;								break;							case "b":								px3 = sourceBmd.getPixel(lockx, locky) & 0xFF;								px4 = sourceBmd.getPixel(i, locky) & 0xFF;								break;							case "av":								px3 = ((sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(lockx, locky) & 0xFF)*0.072169);								px4 = ((sourceBmd.getPixel(i, locky) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(i, locky) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(i, locky) & 0xFF)*0.072169);						}											}										for(k = 0; k < subdivisionX; ++k)					{						incXL = 1/subdivisionX * k;						incXR = 1-incXL;												for(l = 0; l < subdivisionY; ++l)						{							incYL = 1/subdivisionY * l;							incYR = 1-incYL;														pxx = ((px1*incXR) + (px2*incXL))*incYR;							pxy = ((px4*incXR) + (px3*incXL))*incYL;							 							levelBmd.setPixel(k+i, l+j, pxy+pxx << 16 |  0xFF-(pxy+pxx) << 8 | 0xFF-(pxy+pxx) );						 }						 					}				}				 			}						levelBmd.unlock();		}				/**		 * Apply the generated height source to a bitmapdata. The height information is merged to the source creating a smoother look.		 * 		 * @param	src			The bitmapdata that will be merged.		 * @param	color			[optional]	The color that will be applied. Note that 32 bits color will allow alpha. 0x88FF0000 defines a red with .5 alpha while 0xFF0000 defines a red with no alpha. Default is .5 alpha black.		 * @param	reverse			[optional]	Defines if the color is set using the heightmap from 0-255 or 255-0. Default = true, if a black is used, the darkest are will be at the base of the elevation. 		  * @param	blendmode			[optional] Blendmode to be applyed in the merge. Possible string values are: lighten, multiply, overlay, screen, substract, add, darken, difference, erase, hardlight, invert and layer.Default = "normal";		 */		public function applyHeightGradient(src:BitmapData, color:uint = 0x80000000, reverse:Boolean = true, blendmode:String = "normal"):void		{			var gs:BitmapData;			var scl:Boolean;						if(src.width != levelBmd.width || src.height != levelBmd.height){				scl = true;				gs = levelBmd.clone();				var sclmat:Matrix = new Matrix();				var Wscl:Number = gs.width/src.width;				var Hscl:Number = gs.height/src.height;				sclmat.scale(Wscl, Hscl);				var sclbmd:BitmapData = new BitmapData(gs.width * Wscl, gs.height * Hscl, true, 0x00FFFFFF);				sclbmd.draw(gs, sclmat, null, "normal", sclbmd.rect, true);			} else{				gs = levelBmd;			}						var mskBmd:BitmapData = new BitmapData(gs.width, gs.height, true, color);			var z:Point = new Point(0,0);						if(reverse){				mskBmd.copyChannel(gs,gs.rect,z,2,8);			} else{				mskBmd.copyChannel(gs,gs.rect,z,1,8);			}			if(blendmode == "normal"){				src.copyPixels(mskBmd,mskBmd.rect,z,mskBmd,z,true);			}else{				src.draw(mskBmd, null, null, blendmode, mskBmd.rect, true);			}			mskBmd.dispose();						if(scl){				sclbmd.dispose();				gs.dispose();			}		}			}}