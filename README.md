## Magiz v0.4.0
a SketchUp Extension can generate lots of building shapes in seconds
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

2. patterns are saved as mgz file in JSON.and files are in the default extensions folder. (C:\Users\Administrator\AppData\Roaming\SketchUp\SketchUp 2018\SketchUp\Plugins\Zhouxi_Magiz\Resource).every mgz file in this folder will be loaded when SketchUp started.
#### Pattern Editor
to create your own pattern. [Ruby Console Plus](https://github.com/Aerilius/sketchup-console-plus) is needed first.
