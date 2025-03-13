/*
 ┏┓  • ┓  ┏┓  ┏          ┏┓       ┓   •
 ┣ ┏┓┓┏┫┏┓┗┓┏┓╋╋┓┏┏┏┓┏┓┏┓┣ ┏┓┓┏┏┓┏┫┏┓╋┓┏┓┏┓
 ┻ ┛ ┗┗┻┗┻┗┛┗┛┛┗┗┻┛┗┻┛ ┗ ┻ ┗┛┗┻┛┗┗┻┗┻┗┗┗┛┛┗
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */

var menu = 0;
var menuitems = ["play", "credits", "quit"];

var array;
var score;

function genfld()
{
    for (var i = 0; i < 16; i += 4)
    {
        var line = "";
        for (var j = 0; j < 4; j++)
        {
            var val = array[i + j];
            line += (val === 0 ? "." : val) + "\t\t";
        }
        printb(line + "\n\n\n");
    }
    printb("Score: " + score + "\n\n");
    outb();
}

function getEmptyCells()
{
    var empties = [];
    for (var i = 0; i < 16; i++)
    {
        if (array[i] === 0) empties.push(i);
    }
    return empties;
}

function addRandomTile()
{
    var empties = getEmptyCells();
    if (empties.length === 0) return;
    var randPos = empties[Math.floor(Math.random() * empties.length)];
    array[randPos] = Math.random() < 0.9 ? 2 : 4;
}

function noMovesLeft()
{
    for (var i = 0; i < 16; i++)
    {
        if (array[i] === 0) return false;
    }

    for (var row = 0; row < 4; row++)
    {
        for (var col = 0; col < 3; col++)
        {
            var idx = row * 4 + col;
            if (array[idx] === array[idx + 1]) return false;
        }
    }

    for (var col = 0; col < 4; col++)
    {
        for (var row = 0; row < 3; row++)
        {
            var idx = row * 4 + col;
            if (array[idx] === array[idx + 4]) return false;
        }
    }

    return true;
}

function moveLeft()
{
    var changed = false;
    for (var r = 0; r < 4; r++)
    {
        var row = [array[r*4], array[r*4+1], array[r*4+2], array[r*4+3]];
        var filtered = row.filter(x => x !== 0);
        var merged = [];
        for (var i = 0; i < filtered.length; i++)
        {
            if (i < filtered.length - 1 && filtered[i] === filtered[i+1])
            {
                var mergedVal = filtered[i] * 2;
                score += mergedVal;
                merged.push(mergedVal);
                i++;
            } else
            {
                merged.push(filtered[i]);
            }
        }
        while (merged.length < 4) merged.push(0);
        for (var c = 0; c < 4; c++)
        {
            if (array[r*4+c] !== merged[c])
            {
                changed = true;
            }
            array[r*4+c] = merged[c];
        }
    }
    return changed;
}

function rotateBoard()
{
    var newArray = new Array(16);
    for (var r = 0; r < 4; r++)
    {
        for (var c = 0; c < 4; c++)
        {
            newArray[c*4 + (3 - r)] = array[r*4 + c];
        }
    }
    array = newArray;
}

function moveRight()
{
    rotateBoard();
    rotateBoard();
    var changed = moveLeft();
    rotateBoard();
    rotateBoard();
    return changed;
}

function moveUp()
{
    rotateBoard();
    rotateBoard();
    rotateBoard();
    var changed = moveLeft();
    rotateBoard();
    return changed;
}

function moveDown()
{
    rotateBoard();
    var changed = moveLeft();
    rotateBoard();
    rotateBoard();
    rotateBoard();
    return changed;
}

function play()
{
    array = new Array(16).fill(0);
    score = 0;
    addRandomTile();
    addRandomTile();
    clear();
    genfld();

    while (true)
    {
        var ch = getchar();
        var moved = false;
        if (ch === 'w')
        {
            moved = moveUp();
        } else if (ch === 'a')
        {
            moved = moveLeft();
        } else if (ch === 's')
        {
            moved = moveDown();
        } else if (ch === 'd')
        {
            moved = moveRight();
        } else if (ch === 'q')
        {
            break;
        }

        if (moved)
        {
            addRandomTile();
        }

        clear();
        genfld();

        if (noMovesLeft())
        {
            clear();
            sleep(2);
            printb("Game Over! Final Score: " + score + "\n");
            printb("Press any key to return to the menu...\n");
            outb();
            getchar();
            break;
        }
    }
}

function showCredits()
{
    clear();
    printb("2048 JSOS Port\n");
    printb("Sean Boleslawski\n");
    printb("Press any key to return to the menu.\n");
    outb();
    getchar();
}

function render()
{
    clear();
    printb("Use W/S to select, Enter to choose.\n");
    for (var i = 0; i < menuitems.length; i++)
    {
        if (menu == i)
        {
            printb("> " + menuitems[i] + "\n");
        } else
        {
            printb("  " + menuitems[i] + "\n");
        }
    }
    outb();
}

function trigger()
{
    switch (menu)
    {
        case 0:
            play();
            break;
        case 1:
            showCredits();
            break;
        case 2:
            exit();
            break;
        default:
            return;
    }
}

function determine(char)
{
    switch (char)
    {
        case "w":
            if (menu > 0)
            {
                menu--;
            }
            break;
        case "s":
            if (menu < 2)
            {
                menu++;
            }
            break;
        case "\n":
            trigger();
            break;
        default:
            return;
    }
}

function main(args)
{
    clear();
    while (true)
    {
        render();
        var char = getchar();
        determine(char);
    }
}
