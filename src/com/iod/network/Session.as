package com.iod.network
{
	import com.iod.network.Connection;
	import com.iod.network.Packet;
	import com.iod.pb.common.BaseMsg;
	import com.netease.protobuf.Message;
	import com.netease.protobuf.fieldDescriptors.FieldDescriptor_TYPE_MESSAGE;
	
	import flash.utils.ByteArray;
	
	public class Session
	{
		private var connection:Connection;	
		
		private var messageHandlers : Array;
		
		public function Session()
		{
			messageHandlers = new Array;
		}
		
		public function setMesageHandler(id:Number, handleFunction:Function) : void
		{
			messageHandlers[id] = handleFunction;
		}
		
		public function connect(ip:String, port:Number) : void
		{
			if (connection)
				connection.close();
			
			connection = new Connection(this, ip, port, 0);
		}
		
		public function onConnected() : void
		{
			
		}
		
		public function onConnectFailed() : void
		{
			
		}
		
		public function onClosed() : void
		{
			
		}
		
		public function onPacket(packet:Packet) : void
		{
			var baseMsg:BaseMsg = new BaseMsg;
			baseMsg.mergeFrom(packet.data);
			onBaseMessage(baseMsg);
		}
		
		public function onBaseMessage(baseMsg:BaseMsg):void
		{
			if (messageHandlers[baseMsg.messageId] != null)
				messageHandlers[baseMsg.messageId](baseMsg);
		}
		
		public function sendPacket(packet:Packet):Boolean
		{
			return packet.write(connection.socket);
		}
		
		
		private function sendBaseMessage(msg:BaseMsg) : void
		{
			var packet:Packet = new Packet;
			var data :ByteArray = packet.allocateData();
			msg.writeTo(data);
			packet.write(connection.socket);
		}
		
		public function sendMessage(fieldId : FieldDescriptor_TYPE_MESSAGE, msg:Message) : void
		{
			var baseMsg:BaseMsg = new BaseMsg;
			baseMsg.messageId = fieldId.tagNumber;
			baseMsg[fieldId] = msg;
			sendBaseMessage(baseMsg);
		}
		
		public function get connected():Boolean
		{
			return connection.connected;
		}
	}
}