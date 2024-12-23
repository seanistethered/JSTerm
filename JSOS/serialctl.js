/*
 ┏┓  • ┓  ┏┓  ┏          ┏┓       ┓   •
 ┣ ┏┓┓┏┫┏┓┗┓┏┓╋╋┓┏┏┏┓┏┓┏┓┣ ┏┓┓┏┏┓┏┫┏┓╋┓┏┓┏┓
 ┻ ┛ ┗┗┻┗┻┗┛┗┛┛┗┗┻┛┗┻┛ ┗ ┻ ┗┛┗┻┛┗┗┻┗┻┗┗┗┛┛┗
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */

function color(color1, color2)
{
    const predefinedColors =
    {
        blue: { r: 0, g: 0, b: 255 },
        lightblue: { r: 173, g: 216, b: 230 },
        green: { r: 0, g: 255, b: 0 },
        red: { r: 255, g: 0, b: 0 },
        orange: { r: 255, g: 165, b: 0 },
        purple: { r: 128, g: 0, b: 128 },
        black: { r: 0, g: 0, b: 0 },
        white: { r: 255, g: 255, b: 255 }
    };
    
    const backgroundColor = predefinedColors[color1.toLowerCase()];
    const textColor = predefinedColors[color2.toLowerCase()];
    
    if (!backgroundColor || !textColor) {
        print("Error: Invalid color name. Please use predefined colors.\n");
        return;
    }

    serial_setBackground(backgroundColor.r, backgroundColor.g, backgroundColor.b);
    serial_setTextColor(textColor.r, textColor.g, textColor.b);
}

function size(font)
{
    serial_setTextSize(font);
}

function main(args)
{
    if (!args || args.length < 3) {
        print("Usage: " + args[0] +" [color|font|name] [<backgroundColor> <textColor>|<font size>|<name>]\n\n");
        print("Colors: blue, lightblue, green, red, orange, purple, black, white\n\n");
        print("Font Sizes: 1 to 255\n\n");
        return;
    }
    
    switch (args[1])
    {
            case "color":
                color(args[2],args[3]);
                return;
            case "font":
                size(Number(args[2]));
                break;
            case "name":
                serial_setTitle(args[2]);
                break;
            default:
                return;
    }
}
