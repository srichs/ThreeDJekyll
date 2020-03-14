# 3D Jekyll Page Template #

This repository contains a template that can be used to create a page that displays a 3D printable object using the static site generator `jekyll`. The page contains a canvas where a visual 3D display of the object is provided using the [`three.js`](https://github.com/mrdoob/three.js/) library. The page also contains some basic information about what the object is, the cost of the filament to print the object, and it provides links to the files for download. It is created so that no `html` needs to be changed and only the `yaml` Front Matter needs to be updated. There are options available on the page that allow a user to choose to have the object orbit using `OrbitControls.js` or it can be stationary, either way a mouse click and drag on the canvas will allow the camera to be rotated around the object. There are also option to display the object as a wireframe or shaded object.

## template.html ##
#### `yaml` Front Matter ####
``` yaml
---
layout: default
permalink: /3d_print/drawer_part/
p_title: Drawer Bracket
d_value: 1.2
m_filepath: /assets/models/DrawerPart/
m_filename: DrawerPart
m_description: A bracket for a drawer.
m_detail: This item should be printed with PLA or ABS plastic.
m_cost: $0.21
m_filetype_1: .stl
m_filetype_2: .dae
m_filetype_3: .gcode
m_filetype_4: .glb
---
```

`p_title: Drawer Bracket` - This is the title to be used for the tab and header of the page.

`d_value: 1.2` - This is value is used to scale the displayed 3D object.

`m_filepath: /assets/models/DrawerPart/` - This is the path to where the 3D models are stored. All the file types of the model should be saved in one folder. Each file should have the same filename and the extension should be the only difference between each file.

`m_filename: DrawerPart` - This is the filename for the 3D model, all files should have the same name with only the extension being different. i.e. `SomeFile.stl`, `SomeFile.dae`, `SomeFile.gcode`, `SomeFile.glb`, etc.

`m_description: A bracket for a drawer.` - This is used to provide a brief overview of the 3D object.

`m_detail: This item should be printed with PLA or ABS plastic.` - This is used to provide a detailed description of the object.

`m_cost: $0.21` - This is used to display the approximate cost of the filament used to print the object.

`m_filetype_1: .stl` - This is used to display a link to the file to download. If more or less than four files are used then the bottom portion of the `html` file will need to be updated to add or remove the filetypes that aren't used.

File Type changes located at the bottom of the `template.html` file:
``` html
<a href="{{ site.url }}{{ page.m_filepath }}{{ page.m_filename }}{{ page.m_filetype_1 }}">{{ page.m_filename }}{{ page.m_filetype_1 }}</a><br>
<a href="{{ site.url }}{{ page.m_filepath }}{{ page.m_filename }}{{ page.m_filetype_2 }}">{{ page.m_filename }}{{ page.m_filetype_2 }}</a><br>
<a href="{{ site.url }}{{ page.m_filepath }}{{ page.m_filename }}{{ page.m_filetype_3 }}">{{ page.m_filename }}{{ page.m_filetype_3 }}</a><br>
<a href="{{ site.url }}{{ page.m_filepath }}{{ page.m_filename }}{{ page.m_filetype_4 }}">{{ page.m_filename }}{{ page.m_filetype_4 }}</a>
```

The above shows the lines for four file types.

## Dependencies ##
There are several dependencies from the [`three.js`](https://github.com/mrdoob/three.js/) library that are required in order for the template to function correctly.

`JavaScript` changes depending on where the sites files are saved (in the `<head>` of the `template.html` file):

``` html
<script src="{{ site.url }}/assets/js/WebGL.js"></script>
<script src="{{ site.url }}/assets/js/three.js"></script>
<script src="{{ site.url }}/assets/js/STLLoader.js"></script>
<script src="{{ site.url }}/assets/js/OrbitControls.js"></script>
<script src="{{ site.url }}/assets/js/stlviewer.js"></script>
```

The above will need to be changed depending on where the site saves its assets. All of the above `JavaScript` files are required for the 3D display to function correctly. The `stlviewer.js` file is part of this repository. The other files are part of the [`three.js`](https://github.com/mrdoob/three.js/) library. The `stlviewer.js` file is based on code by [tonyb486](https://github.com/tonyb486/stlviewer). 

![image.png](image.png)