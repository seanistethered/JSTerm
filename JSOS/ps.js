/*
 ┏┓  • ┓  ┏┓  ┏          ┏┓       ┓   •
 ┣ ┏┓┓┏┫┏┓┗┓┏┓╋╋┓┏┏┏┓┏┓┏┓┣ ┏┓┓┏┏┓┏┫┏┓╋┓┏┓┏┓
 ┻ ┛ ┗┗┻┗┻┗┛┗┛┛┗┗┻┛┗┻┛ ┗ ┻ ┗┛┗┻┛┗┗┻┗┻┗┗┗┛┛┗
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */
 
function main(args)
{
    var pidlist = getallpid();
    print("PID\tUID\tGID\tPATH\n");
    for (var i = 0; i < pidlist.length; i++)
    {
        print(pidlist[i] + "\t" + getuidpid(pidlist[i]) + "\t" + getgidpid(pidlist[i]) + "\t" + getnamepid(pidlist[i]) + "\n");
    }
}
