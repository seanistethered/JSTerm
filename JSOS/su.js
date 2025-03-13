/*
 ┏┓  • ┓  ┏┓  ┏          ┏┓       ┓   •
 ┣ ┏┓┓┏┫┏┓┗┓┏┓╋╋┓┏┏┏┓┏┓┏┓┣ ┏┓┓┏┏┓┏┫┏┓╋┓┏┓┏┓
 ┻ ┛ ┗┗┻┗┻┗┛┗┛┛┗┗┻┛┗┻┛ ┗ ┻ ┗┛┗┻┛┗┗┻┗┻┗┗┗┛┛┗
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */

function execute(binary, args)
{
    let bin = getenv("bin");
    let bins = tokenizer(bin, ":");
    for (var i = 0; i < bins.length; i++) {
        let cbin = bins[i];
        let dir = fs_list(cbin);
        if (dir.includes(binary + ".js"))
        {
            let cbinary = cbin + "/" + binary + ".js";
            exec(cbinary, "main", args, 1);
            return;
        }
    }
}

function main(args)
{
    let request = Number(args[1]);
    if (request != getuid())
    {
        if (setuid(request) != 0)
        {
            print("setuid: permission denied\n");
            return;
        }
    }
    if (request != getgid())
    {
        if (setgid(request) != 0)
        {
            print("setgid: permission denied\n");
            return;
        }
    }
    
    args.shift();
    args.shift();
    execute(args[0], args);
}
