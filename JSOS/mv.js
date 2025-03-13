//
//  mv.js
//  JSTerm
//
//  Created by fridakitten on 11.03.25.
//

function main(args)
{
    try {
        fs_move(args[1], args[2]);
    } catch (error) {
        print(error.message + "\n");
    }
}
