// I2C device class (I2Cdev) demonstration Processing sketch for MPU6050 DMP output
// 6/20/2012 by Jeff Rowberg <jeff@rowberg.net>
// Updates should (hopefully) always be available at https://github.com/jrowberg/i2cdevlib
//
// Changelog:
//     2012-06-20 - initial release

/* ============================================
I2Cdev device library code is placed under the MIT license
Copyright (c) 2012 Jeff Rowberg

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
===============================================
*/

import processing.serial.*;
import processing.opengl.*;
import toxi.geom.*;
import toxi.processing.*;

// NOTE: requires ToxicLibs to be installed in order to run properly.
// 1. Download from http://toxiclibs.org/downloads
// 2. Extract into [userdir]/Processing/libraries
//    (location may be different on Mac/Linux)
// 3. Run and bask in awesomeness

ToxiclibsSupport gfx;

Serial port;                         // The serial port
char[] teapotPacket = new char[20];  // InvenSense Teapot packet
int serialCount = 0;                 // current packet byte position
int aligned = 0;
int interval = 0;

float[] q = new float[4];
Quaternion quat = new Quaternion(0, 0, 0, 0);//was (1, 0, 0, 0)
float aa[] = {0.0f, 0.0f, 0.0f};

float pos[] = {0, 0, 0};

float[] gravity = {0.0f, 0.0f, 0.0f};//new float[3];
int[] velocity = {0, 0, 0};//new float[3];
int velTime=0;
float[] gravitySt = {0.0f, 0.0f, 0.0f};//new float[3];
float[] euler = new float[3];
float[] ypr = new float[3];

float xCoord = 0.0f;

void setup() {
    // 300px square viewport using OpenGL rendering
    size(640, 480, OPENGL);
    gfx = new ToxiclibsSupport(this);

    // setup lights and antialiasing
    lights();
    smooth();
  
    // display serial port list for debugging/clarity
    //println(Serial.list());

    // get the first available port (use EITHER this OR the specific port code below)
    //String portName = Serial.list()[0];
    
    // get a specific serial port (use EITHER this OR the first-available code above)
    String portName = "/dev/ttyACM0";
    
    // open the serial port
    port = new Serial(this, portName, 115200);
    
    // send single character to trigger DMP init/start
    // (expected by MPU6050_DMP6 example Arduino sketch)
    port.write('r');
}

void draw() {
    if (millis() - interval > 1000) {
        // resend single character to trigger DMP init/start
        // in case the MPU is halted/reset while applet is running
        port.write('r');
        interval = millis();
    }
    
    // black background
    background(0);
    fill(0, 255, 0, 200);
    text("Accel (°/s):\n" + 
               round(gravity[0]*10000)/10 + " - right/left\n" + 
               round(gravity[1]*10000)/10 + " - forward/backward\n" + 
               round(gravity[2]*10000)/10 + " - up/down", 20, 20);


    text("Velocity:\n" + 
               velocity[0] + " - right/left\n" + 
               velocity[1] + " - forward/backward\n" + 
               velocity[2] + " - up/down", 20, 100);
  
    text("Quat :\n" + 
               q[0] + " - ax0\n" + 
               q[1] + " - ax1\n" + 
               q[2] + " - ax2\n" +
               q[3] + " - ax3", 20, 200);
               
    text("ypr:\n" + 
        "Yaw: " + ypr[0]*180.0f/PI + "\n" + 
        "Pitch: " + ypr[1]*180.0f/PI + "\n" + 
        "Roll: " + ypr[2]*180.0f/PI, 20, 280);
    
    // translate everything to the middle of the viewport
    pushMatrix();
    translate(width / 2, height / 2);

    // toxiclibs direct angle/axis rotation from quaternion (NO gimbal lock!)
    // (axis order [1, 3, 2] and inversion [-1, +1, +1] is a consequence of
    // different coordinate system orientation assumptions between Processing
    // and InvenSense DMP)
    float[] axis = quat.toAxisAngle();
    rotate(axis[0], -axis[1], axis[3], axis[2]);

    // translate(pos[0], pos[1], pos[2]);
    // draw main body
    fill(0, 255, 0, 250);
    box(100, 30, 200);
    
    //hint(ENABLE_PERSPECTIVE_CORRECTED_LINES);
    stroke(255, 255, 0);
    line(0, -100, 0, (round(gravity[2]*10000)/100)-100);
    line(0, -100, round(gravity[0]*10000)/-40, -100);
//    line(0, (round(gravity[1]*10000)/-100)-120, 0, -120);



    stroke(0, 255, 0, 100);
    
    popMatrix();
}

void serialEvent(Serial port) {
    interval = millis();
    while (port.available() > 0) {
        int ch = port.read();
        print((char)ch);
        if (aligned < 4) {
            // make sure we are properly aligned on a 14-byte packet
            if (serialCount == 0) {
                if (ch == '$') aligned++; else aligned = 0;
            } else if (serialCount == 1) {
                if (ch == 2) aligned++; else aligned = 0;
            } else if (serialCount == 18) {
                if (ch == '\r') aligned++; else aligned = 0;
            } else if (serialCount == 19) {
                if (ch == '\n') aligned++; else aligned = 0;
            }
            //println(ch + " " + aligned + " " + serialCount);
            serialCount++;
            if (serialCount == 20) serialCount = 0;
        } else {
            if (serialCount > 0 || ch == '$') {
                teapotPacket[serialCount++] = (char)ch;
                if (serialCount == 20) {
                    serialCount = 0; // restart packet byte position
                    
                    // get quaternion from data packet
                    q[0] = ((teapotPacket[2] << 8) | teapotPacket[3]) / 16384.0f;
                    q[1] = ((teapotPacket[4] << 8) | teapotPacket[5]) / 16384.0f;
                    q[2] = ((teapotPacket[6] << 8) | teapotPacket[7]) / 16384.0f;
                    q[3] = ((teapotPacket[8] << 8) | teapotPacket[9]) / 16384.0f;
                    for (int i = 0; i < 4; i++) if (q[i] >= 2) q[i] = -4 + q[i];
                    
                    // set our toxilibs quaternion to new data
                    quat.set(q[0], q[1], q[2], q[3]);

                    aa[0] = ((teapotPacket[10] << 8) | teapotPacket[11]) / 16384.0f;
                    aa[1] = ((teapotPacket[12] << 8) | teapotPacket[13]) / 16384.0f;
                    aa[2] = ((teapotPacket[14] << 8) | teapotPacket[15]) / 16384.0f;

                    // below calculations unnecessary for orientation only using toxilibs
                    
                    // calculate gravity vector
                    gravity[0] = 2 * (q[1]*q[3] - q[0]*q[2]);
                    gravity[1] = 2 * (q[0]*q[1] + q[2]*q[3]);
                    gravity[2] = q[0]*q[0] - q[1]*q[1] - q[2]*q[2] + q[3]*q[3];

                    //experiment
                    if(gravitySt[0]*gravitySt[1]*gravitySt[2]==0){
                      gravitySt[0]=gravity[0];
                      gravitySt[1]=gravity[1];
                      gravitySt[2]=gravity[2];
                    }else{
                      gravity[0]=gravity[0]-gravitySt[0];
                      gravity[1]=gravity[1]-gravitySt[1];
                      gravity[2]=gravity[2]-gravitySt[2];         

                      gravitySt[0]=gravity[0]+gravitySt[0];
                      gravitySt[1]=gravity[1]+gravitySt[1];
                      gravitySt[2]=gravity[2]+gravitySt[2];         

                    //velocity... maybe
                      //if (millis() - velTime >= 500) {
                        velocity[0]=velocity[0]+round(gravity[0]*10000)/10;
                        velocity[1]=velocity[1]+round(gravity[1]*10000)/10;
                        velocity[2]=velocity[2]+round(gravity[2]*10000)/10;
                        //velTime = millis();
                      //}
                    }
                    
                    // calculate yaw/pitch/roll angles
                    ypr[0] = atan2(2*q[1]*q[2] - 2*q[0]*q[3], 2*q[0]*q[0] + 2*q[1]*q[1] - 1);
                    ypr[1] = atan(gravity[0] / sqrt(gravity[1]*gravity[1] + gravity[2]*gravity[2]));
                    ypr[2] = atan(gravity[1] / sqrt(gravity[0]*gravity[0] + gravity[2]*gravity[2]));                    

                    /*
                    // calculate Euler angles
                    euler[0] = atan2(2*q[1]*q[2] - 2*q[0]*q[3], 2*q[0]*q[0] + 2*q[1]*q[1] - 1);
                    euler[1] = -asin(2*q[1]*q[3] + 2*q[0]*q[2]);
                    euler[2] = atan2(2*q[2]*q[3] - 2*q[0]*q[1], 2*q[0]*q[0] + 2*q[3]*q[3] - 1);
        
                    // output various components for debugging
                    //println("q:\t" + round(q[0]*100.0f)/100.0f + "\t" + round(q[1]*100.0f)/100.0f + "\t" + round(q[2]*100.0f)/100.0f + "\t" + round(q[3]*100.0f)/100.0f);
                    //println("euler:\t" + euler[0]*180.0f/PI + "\t" + euler[1]*180.0f/PI + "\t" + euler[2]*180.0f/PI);
                    //println("ypr:\t" + ypr[0]*180.0f/PI + "\t" + ypr[1]*180.0f/PI + "\t" + ypr[2]*180.0f/PI);
                    */
                }
            }
        }
    }
}

