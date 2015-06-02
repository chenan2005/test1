package com.test
{
	import com.iod.network.Netlog;
	import com.iod.network.Session;
	import com.iod.pb.common.BaseMsg;
	import com.iod.pb.test.IDTESTMSG1;
	import com.iod.pb.test.TestMsg1;
	
	import flash.utils.ByteArray;
	
	public class TestClientSession extends Session
	{
		public function TestClientSession()
		{
			setMesageHandler(IDTESTMSG1.tagNumber, onTestMsg1);
		}
		
		public function sendTestMsg1(data:ByteArray) : void
		{
			var t :TestMsg1 = new TestMsg1;
			t.testData = data;
			sendMessage(IDTESTMSG1, t);
		}
		
		public function onTestMsg1(msg:BaseMsg):void
		{
			var t1:TestMsg1 = msg[IDTESTMSG1] as TestMsg1;
			Netlog.log(t1.toString());
		}
	}
}