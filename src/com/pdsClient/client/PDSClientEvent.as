package com.pdsClient.client
{
    import com.pdsClient.util.PDSByteArray;
    
    import flash.events.Event;
    import flash.utils.ByteArray;

    public class PDSClientEvent extends Event
    {
            public static const LOGIN_SUCCESS:String="loginSuccess";
            public static const LOGIN_FAILURE:String="loginFailure";
            public static const LOGIN_REDIRECT:String="loginRedirect";
            public static const RECONNECT_SUCCESS:String="reconnectSuccess";
            public static const RECONNECT_FAILURE:String="reconnectFailure";
            public static const SESSION_MESSAGE:String="sessionMessage";
            public static const LOGOUT:String="logout";
            public static const CHANNEL_JOIN:String="channelJoin";
            public static const CHANNEL_MESSAGE:String="channelMessage";
            public static const CHANNEL_LEAVE:String="channelLeave";
            public static const RAW_MESSAGE:String="rawMessage";

            public var failureMessage:String;
            public var sessionMessage:ByteArray;
            public var channelMessage:ByteArray;
            public var rawMessage:PDSByteArray;
            public var channel:ClientChannel;
            public var host:String;
            public var port:int;

            public function PDSClientEvent(type:String)
            {
                    super(type);
            }
    }
}