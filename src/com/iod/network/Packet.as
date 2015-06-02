package com.iod.network
{
	import com.iod.network.Netlog;
	
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class Packet
	{
		private var _data : ByteArray = null;
		
		public function Packet()
		{
		}
		
		public function read(readBuffer:ByteArray) : Number
		{
			try {
				var positionBackup:uint = readBuffer.position;
				var length : int = readBuffer.readShort();
				if (length > readBuffer.bytesAvailable) {
					readBuffer.position = positionBackup;
					return 0;
				}
				_data = new ByteArray;
				readBuffer.readBytes(_data, 0, length);
				return length + 2;
			}
			catch (error:IOError) {
				return 0;
			}
			catch (error:EOFError) {
				return 0;
			}
			return 0;
		}
		
		public function write(sd:Socket) : Boolean
		{
			try {
				sd.writeShort(_data.length);
				sd.writeBytes(_data);
				sd.flush();
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