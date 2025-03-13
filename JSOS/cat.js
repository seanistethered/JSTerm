/*
 ┏┓  • ┓  ┏┓  ┏          ┏┓       ┓   •
 ┣ ┏┓┓┏┫┏┓┗┓┏┓╋╋┓┏┏┏┓┏┓┏┓┣ ┏┓┓┏┏┓┏┫┏┓╋┓┏┓┏┓
 ┻ ┛ ┗┗┻┗┻┗┛┗┛┛┗┗┻┛┗┻┛ ┗ ┻ ┗┛┗┻┛┗┗┻┗┻┗┗┗┛┛┗
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */

function main(args)
{    
    try {
        let content = fs_read(args[1]);
        print(content + "\n");
    } catch (error) {
        print(error.message + "\n");
    }
}
