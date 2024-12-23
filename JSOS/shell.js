/*
 ┏┓  • ┓  ┏┓  ┏          ┏┓       ┓   •
 ┣ ┏┓┓┏┫┏┓┗┓┏┓╋╋┓┏┏┏┓┏┓┏┓┣ ┏┓┓┏┏┓┏┫┏┓╋┓┏┓┏┓
 ┻ ┛ ┗┗┻┗┻┗┛┗┛┛┗┗┻┛┗┻┛ ┗ ┻ ┗┛┗┻┛┗┗┻┗┻┗┗┗┛┛┗
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */

let hostname = gethostname();
const asciiArt = `
 ┏┓  • ┓  ┏┓  ┏          ┏┓       ┓   •
 ┣ ┏┓┓┏┫┏┓┗┓┏┓╋╋┓┏┏┏┓┏┓┏┓┣ ┏┓┓┏┏┓┏┫┏┓╋┓┏┓┏┓
 ┻ ┛ ┗┗┻┗┻┗┛┗┛┛┗┗┻┛┗┻┛ ┗ ┻ ┗┛┗┻┛┗┗┻┗┻┗┗┗┛┛┗
`;

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
            exec(cbinary, args, false);
            return;
        }
    }
}

function tui(username)
{
    var input = [""];
    var pwd = getenv("pwd");
    var bin = "";
    while (true)
    {
        input = readline(username + "@" + hostname + ":" + pwd + ":> ");
        input = tokenizer(input, " ");

        switch(input[0])
        {
            case "exit":
                exit();
                break;
            case "cd":
                chdir(input[1]);
                pwd = getenv("pwd");
                break;
            case "artwork":
                print(asciiArt);
                break;
            default:
                execute(input[0], input);
                /*if (dir.includes(input[0] + ".js"))
                {
                    exec(bin + "/" + input[0] + ".js", input, false);
                } else {
                    print("Command not found\n")
                }*/
        }
    }
}

function main()
{
    if (getpid() == 1)
    {
        print(asciiArt);
    }
    tui(getusername(getuid()));
}
