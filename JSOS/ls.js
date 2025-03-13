/*
 ┏┓  • ┓  ┏┓  ┏          ┏┓       ┓   •
 ┣ ┏┓┓┏┫┏┓┗┓┏┓╋╋┓┏┏┏┓┏┓┏┓┣ ┏┓┓┏┏┓┏┫┏┓╋┓┏┓┏┓
 ┻ ┛ ┗┗┻┗┻┗┛┗┛┛┗┗┻┛┗┻┛ ┗ ┻ ┗┛┗┻┛┗┗┻┗┻┗┗┗┛┛┗
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */

function safe_chdir(path) {
    let start_pwd = getenv("pwd");
    try {
        chdir(path);
        let end_pwd = getenv("pwd");
        return start_pwd === end_pwd ? 1 : 0;  // Return 1 if no change, 0 if changed
    } catch (error) {
        return 1;  // Failed to change directory, return 1
    }
}

function buildo_perm(object) {
    const permissions = [
        { flag: object.owner_read, perm: 'r' },
        { flag: object.owner_write, perm: 'w' },
        { flag: object.owner_execute, perm: 'x' },
        { flag: object.group_read, perm: 'r' },
        { flag: object.group_write, perm: 'w' },
        { flag: object.group_execute, perm: 'x' },
        { flag: object.other_read, perm: 'r' },
        { flag: object.other_write, perm: 'w' },
        { flag: object.other_execute, perm: 'x' }
    ];

    return permissions.map(p => p.flag ? p.perm : '-').join('');
}

function main(args) {
    if (typeof args[1] !== 'undefined') {
        let path = args[1];
        if (safe_chdir(path) === 1) {
            printb("error: no such path\n");
            return 1;
        }
    }

    // Get the current directory and list the files
    let currentPwd = getenv("pwd");
    let dir = [];
    try {
        dir = fs_list(currentPwd);
    } catch (error) {
        print(error.message + "\n");
        exit();
    }

    let perms = [];
    let owners = [];
    let groups = [];
    let maxFileNameLength = 0;
    let maxOwnerLength = 0;
    let maxGroupLength = 0;

    // Gather file permissions, owner, group, and determine the max lengths for alignment
    for (let i = 0; i < dir.length; i++) {
        try {
            let filePerms = fs_getperms(currentPwd + "/" + dir[i]);
            perms.push(filePerms);
            
            // Fetch the owner and group names
            let owner = getusername(filePerms.owner);  // Fetch owner by ID
            let group = getusername(filePerms.group);  // Fetch group by ID
            owners.push(owner);
            groups.push(group);

            // Calculate max lengths for file name, owner, and group
            maxFileNameLength = Math.max(maxFileNameLength, dir[i].length);
            maxOwnerLength = Math.max(maxOwnerLength, owner.length);
            maxGroupLength = Math.max(maxGroupLength, group.length);
        } catch (error) {
            print(error.message + "\n");
            exit();
        }
    }

    // Auto-size the tabs based on the max file name, owner, and group length
    let tabSizeFileName = maxFileNameLength + 2;  // Add a little space for padding
    let tabSizeOwner = maxOwnerLength + 2;        // Padding for owner
    let tabSizeGroup = maxGroupLength + 2;        // Padding for group

    // Print the results with proper formatting
    for (let i = 0; i < dir.length; i++) {
        let fileName = dir[i];
        let permissionStr = buildo_perm(perms[i]);
        let owner = owners[i];
        let group = groups[i];

        // Ensure all fields are padded correctly
        let formattedFileName = fileName.padEnd(tabSizeFileName, ' ');  // Pad file name to match tab size
        let formattedOwner = owner.padEnd(tabSizeOwner, ' ');  // Pad owner name
        let formattedGroup = group.padEnd(tabSizeGroup, ' ');  // Pad group name

        // Check if group is undefined or empty, for debugging purposes
        if (!group) {
            printb("Warning: No group for file " + fileName + "\n");
        }

        // Print the output in a `ls -la` style
        printb(formattedFileName + permissionStr + "  " + formattedOwner + formattedGroup + "\n");
    }

    outb();
}
