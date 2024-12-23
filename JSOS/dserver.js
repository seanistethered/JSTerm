//
//  dserver.js
//  JSTerm
//
//  Created by fridakitten on 19.12.24.
//

function main(args)
{
    dbus_register("com.dserver");
    
    while (true) {
        let msg = dbus_waitformsg("com.dserver");
        print(msg + "\n");
    }
}
