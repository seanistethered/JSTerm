/*
 ┏┓  • ┓  ┏┓  ┏          ┏┓       ┓   •
 ┣ ┏┓┓┏┫┏┓┗┓┏┓╋╋┓┏┏┏┓┏┓┏┓┣ ┏┓┓┏┏┓┏┫┏┓╋┓┏┓┏┓
 ┻ ┛ ┗┗┻┗┻┗┛┗┛┛┗┗┻┛┗┻┛ ┗ ┻ ┗┛┗┻┛┗┗┻┗┻┗┗┗┛┛┗
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */

function safe_chdir(path)
{
    let start_pwd = getenv("pwd");
    chdir(path);
    let end_pwd = getenv("pwd");
    
    if(start_pwd == end_pwd)
    {
        return 1;
    } else {
        return 0;
    }
}

function main(args) {
    if (typeof args[1] !== 'undefined') {
        let path = args[1];
        if(safe_chdir(path) == 1)
        {
            print("error: no such path\n");
            return 1;
        }
    }
    
    let dir = fs_list(getenv("pwd"));
    
    // Initialize arrays to store items, owners, and groups
    let items = [];
    let owners = [];
    let groups = [];
    
    // Populate the arrays and determine maximum lengths
    let maxItemLength = "ITEM".length;
    let maxOwnerLength = "OWNER".length;
    let maxGroupLength = "GROUP".length;
    
    for (var i = 0; i < dir.length; i++) {
        let item = dir[i];
        let owner = getusername(getown(item));
        let group = getusername(getgrp(item));
        
        items.push(item);
        owners.push(owner);
        groups.push(group);
        
        if (item.length > maxItemLength) {
            maxItemLength = item.length;
        }
        if (owner.length > maxOwnerLength) {
            maxOwnerLength = owner.length;
        }
        if (group.length > maxGroupLength) {
            maxGroupLength = group.length;
        }
    }
    
    // Function to pad strings with spaces
    function pad(str, length) {
        while (str.length < length) {
            str += ' ';
        }
        return str;
    }
    
    // Print header with padding
    let header = pad("ITEM", maxItemLength) + "  " + pad("OWNER", maxOwnerLength) + "  " + pad("GROUP", maxGroupLength);
    print(header + "\n");
    
    // Print a separator line
    let separator = "-".repeat(maxItemLength) + "  " + "-".repeat(maxOwnerLength) + "  " + "-".repeat(maxGroupLength);
    print(separator + "\n");
    
    // Print each item with padding
    for (var i = 0; i < items.length; i++) {
        let line = pad(items[i], maxItemLength) + "  " + pad(owners[i], maxOwnerLength) + "  " + pad(groups[i], maxGroupLength);
        print(line + "\n");
    }
}
