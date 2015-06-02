package com.iod.network
{
	import com.iod.network.Netlog;
	import com.iod.network.Packet;
	import com.iod.network.Session;
	
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class Connection
	{
		public static const CONN_STATE_NONE : Number = 0;
		public static const CONN_STATE_CONNECTING : Number  = 1;
		public static const CONN_STATE_CONNECTED : Number  = 2;
		
		public static const MAX_BUFFER_LENGTH : Number = 1048576;
		public static const RESET_BUFFER_BOUNDARY : Number = 1024;
		
		private var sd:Socket; 
		private var ip:String;
		private var port:Number;
		private var timeoutTime:Number;
		private var timoutHandle:uint;
		private var state:Number;
		private var readBuffer:ByteArray;
		
		private var bindSession:Session;
		
		public function Connection(session:Session, ip:String, port:Number, timeoutTime:Number) : void
		{
			this.bindSession = session;
			this.ip = ip;
			this.port = port;
			this.timeoutTime = timeoutTime;
			this.readBuffer = new ByteArray;
			
			reconnect();
		}
		
		public function close():void
		{
			if (sd) {
				sd.close();
				sd = null;
				setConnState(CONN_STATE_NONE);
				if (bindSession)
					bindSession.onClosed();
			}
		}
				
		public function reconnect():void
		{
			if (sd)
				this.close();
			
			sd = new Socket();			
			sd.addEventListener(Event.CONNECT, onConnected);
			sd.addEventListener(IOErrorEvent.IO_ERROR, onConnectError);
			sd.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onConnectError);
			
			sd.connect(this.ip, this.port);
			Netlog.log("start connecting " + ip + ":" + port + " ...");
			
			setConnState(CONN_STATE_CONNECTING);
		}
		
		public function get connected():Boolean
		{
			return this.state == CONN_STATE_CONNECTED && sd.connected;
		}
		
		public function get connState():Number
		{
			return this.state;
		}
		
		public function get socket():Socket
		{
			return this.sd;
		}
		
		private function onConnected(event:Event) : void
		{
			Netlog.log("target " + ip + ":" + port + " connected");
			sd.addEventListener(Event.CLOSE, onClosed);
			sd.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			sd.removeEventListener(IOErrorEvent.IO_ERROR, onConnectError);
			sd.addEventListener(IOErrorEvent.IO_ERROR, onSocketDataError);
			setConnState(CONN_STATE_CONNECTED);
			if (bindSession)
				bindSession.onConnected();
		}
		
		private function onConnectError(event:Event):void
		{
			Netlog.log("target " + ip + ":" + port + " connect failed:" + event.toString());
			sd = null;
			setConnState(CONN_STATE_NONE);
			if (bindSession)
				bindSession.onConnectFailed();
		}
		
		private function onClosed(event:Event):void
		{
			Netlog.log("connection close: " + event.toString());
			setConnState(CONN_STATE_NONE);
			if (bindSession)
				bindSession.onClosed();
		}
		
		private function onTimeout():void
		{
			Netlog.log("target " + ip + ":" + port + " connection timeout ");
			this.close();
		}
		
		private function resetTimeout():void
		{
			disableTimeout();
			if (this.timeoutTime > 0)
				this.timoutHandle = setTimeout(onTimeout, this.timeoutTime);
		}
		
		private function disableTimeout():void
		{
			if (this.timoutHandle > 0)
				clearTimeout(this.timoutHandle);
		}
		
		private function setConnState(state:Number):void
		{
			this.state = state;
			if (this.state == CONN_STATE_NONE)
				disableTimeout();
			else
				resetTimeout();
		}
		
		private function onSocketData(event:ProgressEvent):void
		{
			if (!bindSession)
				return;
			
			//当读取缓冲区小于MAX_BUFFER_LENGTH时，才读取数据
			if (readBuffer.length < MAX_BUFFER_LENGTH) {
				try {
					sd.readBytes(readBuffer, readBuffer.length);
				}
				catch (error:EOFError) {
					Netlog.log(error.message);
					close();
				}
				catch (error:IOError) {
					Netlog.log(error.message);
					close();
				}
			}
			
			//读取网络包
			var packet : Packet = new Packet;
			while (packet.read(readBuffer) > 0) {
				bindSession.onPacket(packet);
			}
			
			//如果读取位置在最后，直接清空缓冲区
			if (readBuffer.position == readBuffer.length) {
				readBuffer.clear();
			}
			//否则将剩余数据复制到新的缓冲区中
			else if (readBuffer.position > RESET_BUFFER_BOUNDARY) {
				var tempBuffer:ByteArray = new ByteArray;
				tempBuffer.writeBytes(readBuffer, readBuffer.position);
				readBuffer = tempBuffer;
			}
		}
		
		private function onSocketDataError(event:IOErrorEvent):void
		{
			Netlog.log("target " + ip + ":" + port + " io error : " + event.toString());
			close();
		}
	}
}