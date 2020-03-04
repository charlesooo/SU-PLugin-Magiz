## Magiz v0.4.0
a SketchUp Extension can generate lots of building shapes in seconds
![demo](https://github.com/charlesooo/Magiz/blob/master/Magiz_Demo.gif)

***
#### Basic operation
1. select some groups or components   
2. click a toolbar icon (from left to right:generate with details/generate without details/reset to a cube/pattern manager)   
3. when manager is hidden, generation is random. choose a pattern, generation is fixed.   
***
#### Mechanism
1. depending on the height and the class of target, random generation will choose from four categories.
    | -| h<24m | h>24m|
    | --- | ------ | --- |
    | Group | TierBuilding | Skyscraper |
    | Component | Villa | Apartment |

2. patterns are saved as mgz file in JSON.and files are in the default extensions folder. (C:\Users\Administrator\AppData\Roaming\SketchUp\SketchUp 2018\SketchUp\Plugins\Zhouxi_Magiz\Resource).every mgz file in this folder will be loaded when SketchUp start.
***
#### Pattern Editor
to create your own pattern. [Ruby Console Plus](https://github.com/Aerilius/sketchup-console-plus) is needed first.
![demo](https://github.com/charlesooo/Magiz/blob/master/demo.png)   
open Magiz_PTN_Editor.rb, there are two commands in the bottom.click the button in red circle,'save_PTN' will save all the data in red square into a mgz file.'refresh' will generate a building at origin point of the model.'refresh' has three parameters.the first represents certain data in red sqaure. the second represents the height of building, when the third is 0, no details will be generated.

in the end, there are two functions you can write in pattern data. r1/r2/r3 randomly represents 1 or 0. lv(t,h) represents the height of building divides the net height of every floor. functions need to be wrapped by "".
