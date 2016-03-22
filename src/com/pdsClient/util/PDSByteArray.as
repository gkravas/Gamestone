package com.pdsClient.util
{
	import flash.utils.ByteArray;
	
	public class PDSByteArray extends ByteArray {
		
		public function PDSByteArray() {
		}
                
        public function readPDSString():String {
            //TODO error check length
            var strLen:int = readUnsignedShort();
            return readUTFBytes(strLen);
        }
        
        public function readLong():Number
        {
            //TODO error check length
            return  ((readByte() & 255) << 56) + 
                            ((readByte() & 255) << 48) +
                    ((readByte() & 255) << 40) + 
                    ((readByte() & 255) << 32) +
                    ((readByte() & 255) << 24) +
                    ((readByte() & 255) << 16) +
                    ((readByte() & 255) << 8) +
                    ((readByte() & 255) << 0);
        } 
	}
}