//
//  chat.js
//  JSTerm
//
//  Created by fridakitten on 26.12.24.
//

function host(name)
{
    print("server: com.chat." + name + "\n");
    dbus_register("com.chat." + name);
    while(true)
    {
        let msg = dbus_waitformsg("com.chat." + name);
        if (msg == "sd")
        {
            exit();
        }
        print(msg);
    }
}

function join(username, name)
{
    print("server: com.chat." + name + "\n");
    while(true)
    {
        let msg = readline(username + "@" + name + " => ");
        dbus_sendmsg("com.chat." + name, "[" + username + "] " + msg + "\n");
        clear();
    }
}

function main(args)
{
    switch(args[1])
    {
        case "host":
            host(args[2]);
            break;
        case "join":
            join(args[2], args[3]);
            break;
        default:
            exit();
    }
}
