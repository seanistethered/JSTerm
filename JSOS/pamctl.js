/*
 ┏┓  • ┓  ┏┓  ┏          ┏┓       ┓   •
 ┣ ┏┓┓┏┫┏┓┗┓┏┓╋╋┓┏┏┏┓┏┓┏┓┣ ┏┓┓┏┏┓┏┫┏┓╋┓┏┓┏┓
 ┻ ┛ ┗┗┻┗┻┗┛┗┛┛┗┗┻┛┗┻┛ ┗ ┻ ┗┛┗┻┛┗┗┻┗┻┗┗┗┛┛┗
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */

function main(args)
{
    if (!args || args.length < 3) {
        print("Usage: " + args[0] +" [name|call] [<uid> <name>|<uid> [add|rm] <syscall>]\n\nSYSCALLS\nsetuid - allows a process to change their user identifier\nsetgid - allows a process to change their group identifier\nusrmgr - allows a process to manage users/groups\nfsread - allows a process to read from RootFS\nfswrite - allows a process to write to RootFS\nexec - allows a process to execute files\nsysctl - allows a process to get information of other processes\n\n");
        return;
    }
    
    const predefinedCalls =
    {
        setuid:  0x01,
        setgid:  0x02,
        usrmgr:  0x03,
        fsread:  0x04,
        fswrite: 0x05,
        exec:    0x06,
        sysctl:  0x07
    };
    
    switch (args[1])
    {
        case "name":
            setusername(Number(args[2]), args[3]);
            break;
        case "call":
            switch(args[3])
            {
                case "add":
                    setsyscall(Number(args[2]), predefinedCalls[args[4]]);
                    break;
                case "rm":
                    unsetsyscall(Number(args[2]), predefinedCalls[args[4]]);
                    break;
            }
            break;
        default:
            return 0;
    }
}
