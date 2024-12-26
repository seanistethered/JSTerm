//
//  thread_poc.js
//  JSTerm
//
//  Created by fridakitten on 26.12.24.
//

function poc()
{
    dbus_register("com.thread_poc.poc");
    while (true)
    {
        let msg = dbus_waitformsg("com.thread_poc.poc");
        print(msg + "\n");
    }
}

function main(args)
{
    print("starting thread\n");
    cthread("poc");
    sleep(2);
    print("sending message\n");
    dbus_sendmsg("com.thread_poc.poc", "hewwo :3");
    sleep(2);
}
