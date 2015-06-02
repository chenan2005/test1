package com.iod.network
{
	import com.iod.network.Connection;
	import com.iod.network.Packet;
	
	public class Session
	{
		private var connection:Connection;	
		
		public function Session()
		{
		}
		
		public function connect(ip:String, port:Number)
		{
			if (connection)
				connection.close();
			
			connection = new Connection(this, ip, port, 0);
		}
		
		public function onConnected()
		{
			
		}
		
		public function onConnectFailed()
		{
			
		}
		
		public function onClosed()
		{
			
		}
		
		public function onPacket(packet:Packet)
		{
			
		}
	}
}