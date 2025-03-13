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
            exec(cbinary, "main", args, 2);
            return;
        }
    }
}

function main(args)
{
    let binary = args[1]
    args.shift()
    execute(binary, args)
}
