import controlP5.*;

ControlP5 cp5;
ControlWindow controlWindow;
ControlWindow viewWindow;
Textlabel readmeText;

ListBox l;

int blendmode = 0;

String imgPath;

PImage img0; // source image(base)
PImage img1; // source image
PImage tuned_img0; // source image(base)
PImage tuned_img1; // source image
PImage writeimg; // multiple exposed image

float gamma_s = 1.0; // gamma value for source image
float gamma_m = 1.0; // gamma value for multiple exposed image

float gain_s = 1;
float gain_m = 1;

float[] lut_s = new float[256];
float[] lut_m = new float[256];

//Window Size
int view_width=1024, view_height=768;
int view_swidth0, view_sheight0;
int view_swidth1, view_sheight1;

int size_sx = 160;
int size_sy = 120;

int size_x = 800;
int size_y = 640;


void TuneImage(){
  for (int i = 0; i < 256; i++){
    lut_s[i] = 255*pow(((float)i/255),(1/gamma_s));
  }

  for (int i = 0; i < 256; i++){
    lut_m[i] = 255*pow(((float)i/255),(1/gamma_m));
  }

  tuned_img0 = createImage(img0.width, img0.height, RGB);
  tuned_img1 = createImage(img1.width, img1.height, RGB);

  img0.loadPixels();
  img1.loadPixels();

  for(int i = 0; i < img0.width*img0.height; i++){
    color tmp_color = img0.pixels[i];

    int tmp_r = (int)(lut_s[(int)red(tmp_color)]*gain_s);
    int tmp_g = (int)(lut_s[(int)green(tmp_color)]*gain_s);
    int tmp_b = (int)(lut_s[(int)blue(tmp_color)]*gain_s);
     
    tuned_img0.pixels[i] = color(tmp_r, tmp_g, tmp_b);
  }

  for(int i = 0; i < img1.width*img1.height; i++){
    color tmp_color = img1.pixels[i];

    int tmp_r = (int)(lut_m[(int)red(tmp_color)]*gain_m);
    int tmp_g = (int)(lut_m[(int)green(tmp_color)]*gain_m);
    int tmp_b = (int)(lut_m[(int)blue(tmp_color)]*gain_m);

    tuned_img1.pixels[i] = color(tmp_r, tmp_g, tmp_b);
  }
}

void ImageMultiExposed(){
  writeimg = createImage(img0.width, img0.height, RGB);

  if(writeimg.width > size_x || writeimg.height > size_y){
    float k_width = (float)writeimg.width / (float)size_x;
    float k_height = (float)writeimg.height / (float)size_y;
    float k_max;

    if(k_width > k_height){
      k_max = k_width;
    }else{
      k_max = k_height;
    }

    view_width = (int)(writeimg.width/k_max);
    view_height = (int)(writeimg.height/k_max);
  }else{
    view_width = writeimg.width;
    view_height = writeimg.height;
  }

  tuned_img0.loadPixels();
  tuned_img1.loadPixels();

  switch(blendmode){
    case 1: // Screen
      for(int i = 0; i < img0.width*img0.height; i++){
        color tmp_color0 = tuned_img0.pixels[i];
        color tmp_color1 = tuned_img1.pixels[i];
        int r = ((int)red(tmp_color0) + (int)red(tmp_color1))
                - ((int)red(tmp_color0) * (int)red(tmp_color1))/0xff;
        int g = ((int)green(tmp_color0) + (int)green(tmp_color1))
                -((int)green(tmp_color0) * (int)green(tmp_color1))/0xff;
        int b = ((int)blue(tmp_color0) + (int)blue(tmp_color1))
                -((int)blue(tmp_color0) * (int)blue(tmp_color1))/0xff;
        writeimg.pixels[i] = color(r,g,b);
      }
      break;
    case 2: // Multiply
      for(int i = 0; i < img0.width*img0.height; i++){
        color tmp_color0 = tuned_img0.pixels[i];
        color tmp_color1 = tuned_img1.pixels[i];
        int r = ((int)red(tmp_color0) * (int)red(tmp_color1))/0xff;
        int g = ((int)green(tmp_color0) * (int)green(tmp_color1))/0xff;
        int b = ((int)blue(tmp_color0) * (int)blue(tmp_color1))/0xff;
        writeimg.pixels[i] = color(r,g,b);
      }
      break;
    case 3: // Overlay
      for(int i = 0; i < img0.width*img0.height; i++){
        color tmp_color0 = tuned_img0.pixels[i];
        color tmp_color1 = tuned_img1.pixels[i];
        int r,g,b;
        if((int)red(tmp_color0)>=0x80){
          r = 2*(((int)red(tmp_color0) + (int)red(tmp_color1))
                  - ((int)red(tmp_color0) * (int)red(tmp_color1))/0xff) - 0xff;
        }else{
          r = ((int)red(tmp_color0) * (int)red(tmp_color1)*2)/0xff;
        }

        if((int)green(tmp_color0)>=0x80){
          g = 2*(((int)green(tmp_color0) + (int)green(tmp_color1))
                  - ((int)green(tmp_color0) * (int)green(tmp_color1))/0xff) - 0xff;
        }else{
          g = ((int)green(tmp_color0) * (int)green(tmp_color1)*2)/0xff;
        }

        if((int)blue(tmp_color0)>=0x80){
          b = 2*(((int)blue(tmp_color0) + (int)blue(tmp_color1))
                  - ((int)blue(tmp_color0) * (int)blue(tmp_color1))/0xff) - 0xff;
        }else{
          b = ((int)blue(tmp_color0) * (int)blue(tmp_color1)*2)/0xff;
        }

        writeimg.pixels[i] = color(r,g,b);
      }
      break;
    case 4: // Lighten
      for(int i = 0; i < img0.width*img0.height; i++){
        color tmp_color0 = tuned_img0.pixels[i];
        color tmp_color1 = tuned_img1.pixels[i];
        int r, g, b;
        if((int)red(tmp_color0) >  (int)red(tmp_color1)){
          r =(int)red(tmp_color0);
        }else{
          r =(int)red(tmp_color1);
        }

        if((int)green(tmp_color0) >  (int)green(tmp_color1)){
          g =(int)green(tmp_color0);
        }else{
          g =(int)green(tmp_color1);
        }

        if((int)blue(tmp_color0) >  (int)blue(tmp_color1)){
          b =(int)blue(tmp_color0);
        }else{
          b =(int)blue(tmp_color1);
        }

        writeimg.pixels[i] = color(r,g,b);
      }
      break;
    default:
      break;
  }
  writeimg.updatePixels();
}

void setup(){
  size(size_x, size_y+size_sy);

  cp5 = new ControlP5(this);

  controlWindow = cp5.addControlWindow("Tunewindow", 100, 100, 360, 600)
    .hideCoordinates()
    .setBackground(color(40))
    ;

  cp5.addButton("Load Source Image")
     .setPosition(40,40)
     .setSize(130,39)
     .moveTo(controlWindow)
     ;

  cp5.addSlider("gamma_s")
     .setRange(0, 2)
     .setPosition(40, 100)
     .setSize(100, 25)
     .moveTo(controlWindow)
     ;

  cp5.addSlider("gain_s")
     .setRange(0, 4)
     .setPosition(40, 140)
     .setSize(100, 25)
     .moveTo(controlWindow)
     ;

  cp5.addButton("Load MultipleExposed Image")
     .setPosition(200,40)
     .setSize(130,39)
     .moveTo(controlWindow)
     ;

  cp5.addSlider("gamma_m")
     .setRange(0, 2)
     .setPosition(200, 100)
     .setSize(100, 25)
     .moveTo(controlWindow)
     ;

  cp5.addSlider("gain_m")
     .setRange(0, 4)
     .setPosition(200, 140)
     .setSize(100, 25)
     .moveTo(controlWindow)
     ;

  l = cp5.addListBox("myList")
         .setPosition(40, 250)
         .setSize(120, 180)
         .setItemHeight(39)
         .setBarHeight(20)
         .setColorBackground(color(40, 128))
         .setColorActive(color(255, 128))
         .moveTo(controlWindow)
         ;

  l.captionLabel().toUpperCase(true);
  l.captionLabel().set("MultiExposed Mode");
  l.captionLabel().setColor(0xffff0000);
  l.captionLabel().style().marginTop = 3;
  l.valueLabel().style().marginTop = 3;
  
  ListBoxItem lbi;
  lbi = l.addItem("Screen", 0);
  lbi.setColorBackground(0xffff0000);
  lbi = l.addItem("Multiply", 1);
  lbi.setColorBackground(0xffff0000);
  lbi = l.addItem("Overlay", 2);
  lbi.setColorBackground(0xffff0000);
  lbi = l.addItem("Lighten", 3);
  lbi.setColorBackground(0xffff0000);

  cp5.addButton("Save Image")
     .setPosition(40,500)
     .setSize(100,39)
     .moveTo(controlWindow)
     ;

  cp5.addButton("Exit")
     .setPosition(160,500)
     .setSize(100,39)
     .moveTo(controlWindow)
     ;

  img0 = createImage(size_sx, size_sy, RGB);
  img1 = createImage(size_sx, size_sy, RGB);
  writeimg = createImage(size_x, size_y, RGB);
}

public void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom("Load Source Image")) {
    imgPath = selectInput();
    img0 = loadImage(imgPath);

    if(img0.width > size_sx || img0.height > size_sy){
      float k_width = (float)img0.width / (float)size_sx;
      float k_height = (float)img0.height / (float)size_sy;
      float k_max;

      if(k_width > k_height){
        k_max = k_width;
      }else{
        k_max = k_height;
      }
      view_swidth0 = (int)(img0.width/k_max);
      view_sheight0 = (int)(img0.height/k_max);
    }else{
      view_swidth0 = img0.width;
      view_sheight0 = img0.height;
    }
  }

  if(theEvent.isFrom("Load MultipleExposed Image")) {
    imgPath = selectInput();
    img1 = loadImage(imgPath);

    if(img1.width > size_sx || img1.height > size_sy){
      float k_width = (float)img1.width / (float)size_sx;
      float k_height = (float)img1.height / (float)size_sy;
      float k_max;

      if(k_width > k_height){
        k_max = k_width;
      }else{
        k_max = k_height;
      }
      view_swidth1 = (int)(img1.width/k_max);
      view_sheight1 = (int)(img1.height/k_max);
    }else{
      view_swidth1 = img1.width;
      view_sheight1 = img1.height;
    }
  }

  if (theEvent.isGroup()) {
    // an event from a group e.g. scrollList
    // +1 is offset
    blendmode = (int)theEvent.group().value()+1;
  }

  if(theEvent.isFrom("Save Image")) {
    String imgPath = selectOutput();
    writeimg.save(imgPath);
  }

  if(theEvent.isFrom("Exit")) {
    exit();
  }
}

void draw(){
  background(0);
  tuned_img0 = img0;
  tuned_img1 = img1;

  if(img0.width == img1.width && img0.height == img1.height){
    TuneImage();
    ImageMultiExposed();
  }

  image(tuned_img0, 0, 0, view_swidth0, view_sheight0);
  image(tuned_img1, size_sx, 0, view_swidth1, view_sheight1);

  if(img0.width == img1.width && img0.height == img0.height){
    image(writeimg, 0, size_sy, view_width, view_height);
  }
}