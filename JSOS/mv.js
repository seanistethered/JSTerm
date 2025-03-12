//
//  mv.js
//  JSTerm
//
//  Created by fridakitten on 11.03.25.
//

function main(args)
{
    /*
     Pretty shitty approach on movinf a file, I admit to it, fs_move later will fix this issue
     
     First we read the content of the file
     */
    let content_of_file = fs_read(args[1]);
    
    /*
     Now we remove the file we read the content from
     */
    fs_remove(args[1]);
    
    /*
     Now we write the content to the destination
     */
    fs_write(content_of_file, args[2]);
}
