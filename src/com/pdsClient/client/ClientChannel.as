package com.pdsClient.client
{
	import flash.utils.ByteArray;

        public class ClientChannel {
            private var _name:String;
            private var _id:Number;
            private var _rawId:ByteArray;

            /**
             *  Stores details about the client channel.
             */
            public function ClientChannel(name:String, rawId:ByteArray) {
                _name=name;
                _rawId=rawId;
                _rawId.position=0;
                _id=bytesToChannelId(_rawId);
            }

            public function get name():String {
                return _name;
            }

            public function get id():Number {
                return _id;
            }

            public function get rawId():ByteArray {
                return _rawId;
            }

            //This could very well overflow Number's ability to store values
            //not sure what to do here.  Why does the channel id have to potentially
            //be so huge? *boggle*
            public static function bytesToChannelId(buf:ByteArray):Number {
                var rslt:Number=0;
                var shift:Number=(buf.bytesAvailable - 1) * 8;
                for (var x:int=0; x <= buf.bytesAvailable; x++)
                {
                        var bv:int=buf.readByte();
                        rslt+=(bv & 255) << shift;
                        shift-=8;
                }
                return rslt;
            }
    }
}