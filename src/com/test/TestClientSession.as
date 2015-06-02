package com.test
{
	import com.iod.network.Session;
	import com.iod.pb.test.*;	
	import flash.utils.ByteArray;
	
	public class TestClientSession extends Session
	{
		public function TestClientSession()
		{
		}
		
		public function sendTestMsg1(data:ByteArray) : void
		{
			var t :TestMsg1 = new TestMsg1;
			t.testData = data;
			sendMessage(IDTESTMSG1, t);
		}
	}
}