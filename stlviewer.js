/**
 * MIT License
 * Copyright <2020> <COPYRIGHT Scott Richards>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in the
 * Software without restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so, subject to the
 * following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/**
 * Filename: stlviewer.js
 * Date: 2 Mar 2020 <p>
 *
 * Purpose: This javascript file creates a three.js scene from a .stl file object
 *     and then rotates it using the OrbitControls.js controls from the three.js
 *     library. There are options available to turn on or off autorotate or to
 *     change the material between a wireframe option or a shaded solid.
 *
 * This code is based on stlviewer.js by Anthony Biondo (tonybox.net)
 *
 * @author srichs
 */
"use strict";
var canvas, camera, renderer, scene;
var distScale;
var ambientLight, hemiLight;
var controls;
var element, model;
var mesh1, mesh2;
var orbiting = true;

/** This function is called to change the material of the object when the radio
 * button is selected for the other option. */
function doMaterialChange(modelType) {
    for (var i = scene.children.length - 1; i >= 0; i--) {
        var obj = scene.children[i];
        scene.remove(obj);
    }
    (new THREE.STLLoader()).load(model, function(geometry) {
        var mesh;
        if (modelType == 1) {
            scene.add(ambientLight);
            scene.add(mesh1);
            mesh = mesh1;
        } else if (modelType == 2) {
            scene.add(hemiLight);
            scene.add(mesh2);
            mesh = mesh2;
        }
        var middle = new THREE.Vector3();
        geometry.computeBoundingBox();
        geometry.boundingBox.getCenter(middle);
        mesh.position.x = -1 * middle.x;
        mesh.position.y = -1 * middle.y;
        mesh.position.z = -1 * middle.z;
        render();
    });
}

/** This function initializes the stl object and the materials that will be used
 * for the wireframe and shaded options. */
function initObject() {
    var material1 = new THREE.MeshPhongMaterial({
        color: 0xffffff,
        opacity: 0.85,
        transparent: true,
        polygonOffset: true,
        polygonOffsetFactor: 1, // positive value pushes polygon further away
        polygonOffsetUnits: 1
    });
    var material2 = new THREE.MeshPhongMaterial({
        color: 0x448ead,
        specular: 0x448ead,
        shininess: 100.0,
    });
    (new THREE.STLLoader()).load(model, function(geometry) {
        mesh2 = new THREE.Mesh(geometry, material2);
        mesh2.geometry.computeFaceNormals();
        mesh2.geometry.computeVertexNormals();
        scene.add(mesh2);
        /*var geo = new THREE.EdgesGeometry(mesh2.geometry); // or WireframeGeometry
        var mat = new THREE.LineBasicMaterial({
            color: 0x000000,
            linewidth: 1
        });
        var outline = new THREE.LineSegments(geo, mat);
        mesh2.add(outline);*/
        scene.remove(mesh2);
    });
    (new THREE.STLLoader()).load(model, function(geometry) {
        mesh1 = new THREE.Mesh(geometry, material1);
        mesh1.geometry.computeFaceNormals();
        mesh1.geometry.computeVertexNormals();
        scene.add(mesh1);
        var geo = new THREE.EdgesGeometry(mesh1.geometry); // or WireframeGeometry
        var mat = new THREE.LineBasicMaterial({
            color: 0x000000,
            linewidth: 2
        });
        var outline = new THREE.LineSegments(geo, mat);
        mesh1.add(outline);
        var middle = new THREE.Vector3(); // Compute the middle
        geometry.computeBoundingBox();
        geometry.boundingBox.getCenter(middle);
        mesh1.position.x = -1 * middle.x; // Center it
        mesh1.position.y = -1 * middle.y;
        mesh1.position.z = -1 * middle.z;
        var largestDimension = Math.max(geometry.boundingBox.max.x,
            geometry.boundingBox.max.y, geometry.boundingBox.max.z); // Pull the camera away as needed
        camera.position.z = largestDimension * distScale;
        doFrame();
    });
}

/** gets the checkbox change for the orbit checkbox */
function doControlCheckbox() {
    var orb = document.getElementById("c1").checked
    if (orb != orbiting) {
        orbiting = orb;
        doControlChange();
    }
}

/** changes the autorotate variable of the orbitcontrols */
function doControlChange() {
    if (orbiting) {
        controls.autoRotate = true;
    } else {
        controls.autoRotate = false;
    }
}

/** calls the functions that need to be updated for each frame */
function doFrame() {
    controls.update();
    renderer.render(scene, camera);
    requestAnimationFrame(doFrame);
}

/** this function is called to set the elements of the html and set variables from
 * information provided by the html */
function STLViewerEnable(classname) {
    document.getElementById("c1").checked = orbiting;
    document.getElementById("c1").onchange = function() {
        doControlCheckbox()
    };
    document.getElementById("r1").checked = true;
    document.getElementById("r1").onchange = function() {
        doMaterialChange(1)
    };
    document.getElementById("r2").onchange = function() {
        doMaterialChange(2)
    };
    var models = document.getElementsByClassName(classname);
    for (var i = 0; i < models.length; i++) {
        element = models[i];
        model = models[i].getAttribute("data-src");
        distScale = models[i].getAttribute("data-value");
        STLViewer();
    }
}

/** this function is called to create the canvas and call the initialization of
 * the scene and object */
function STLViewer() {
    if (!WEBGL.isWebGLAvailable()) {
        element.appendChild(WEBGL.getWebGLErrorMessage());
        return;
    }
    try {
        canvas = document.getElementById("glcanvas");
        renderer = new THREE.WebGLRenderer({
            canvas: canvas,
            antialias: true,
            alpha: true
        });
    } catch (e) {
        document.getElementsByClassName("stlViewer").innerHTML =
            "<h3><b>Sorry, WebGL is required but is not available.</b><h3>";
        return;
    }
    initScene(element);
    initObject();
}

/** This function initializes the scene elements */
function initScene() {
    camera = new THREE.PerspectiveCamera(70, element.clientWidth / element.clientHeight, 1, 1000);
    renderer.setSize(element.clientWidth, element.clientHeight);
    element.appendChild(renderer.domElement);

    window.addEventListener('resize', function() {
        renderer.setSize(element.clientWidth, element.clientHeight);
        camera.aspect = element.clientWidth / element.clientHeight;
        camera.updateProjectionMatrix();
    }, false);

    controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.rotateSpeed = 1.0;
    controls.dampingFactor = 0.1;
    controls.enableZoom = true;
    controls.enablePan = false;
    controls.autoRotate = true;
    controls.autoRotateSpeed = 8.0;

    scene = new THREE.Scene();

    ambientLight = new THREE.AmbientLight(0xffffff);
    hemiLight = new THREE.HemisphereLight(0xffffff, 0x080820, 1.5);
    scene.add(ambientLight);
}
