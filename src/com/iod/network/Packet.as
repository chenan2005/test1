package com.iod.network
{
	import flash.errors.IOError;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import com.iod.network.Netlog;
	
	public class Packet
	{
		private var _data : ByteArray = null;
		
		public function Packet()
		{
		}
		
		public function read(readBuffer:ByteArray) : Number
		{
			try {
				var length : int = readBuffer.readShort();
				if (length > readBuffer.bytesAvailable)
					return 0;
				_data = new ByteArray;
				readBuffer.readBytes(_data, 0, length);
				return length + 2;
			}
			catch (error:IOError) {
				return 0;
			}
			return 0;
		}
		
		public function write(sd:Socket) : Boolean
		{
			try {
				sd.writeShort(_data.length);
				sd.writeBytes(_data);
			}
			catch (error:IOError) {
				Netlog.log("write socket error:" + error.message);
				return false;
			}
			return true;
		}
		
		public function allocateData() : ByteArray
		{
			this._data = new ByteArray;
			return this._data;
		}
		
		public function get data() : ByteArray
		{
			return this._data;
		}
	}
}