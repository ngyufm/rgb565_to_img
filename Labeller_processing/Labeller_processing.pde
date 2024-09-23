import java.io.File;

final String imagesToLabelPath = "C:\\Users\\jojoj\\Desktop\\rgb565 to img\\Images";
final String labelJSONPath = "C:\\Users\\jojoj\\Desktop\\rgb565 to img\\Label.json";

JSONObject labels;
String[] assumedValidImgs;

int imgFileLength;
void setup(){
  size(240,240);
  labels = loadJSONObject(labelJSONPath);
  
  File imgFiles[] = listFiles(imagesToLabelPath);
  assumedValidImgs = new String[imgFiles.length];
  for(int i = 0; i < imgFiles.length; i++){
    assumedValidImgs[i] = imgFiles[i].getName();
  }
  assumedValidImgs = sort(assumedValidImgs);
  
  imgFileLength = imgFiles.length;
  
  loadImg();
}

int currentImg = 0;
int selection = 0;
void keyPressed(){
  switch(keyCode){
    case LEFT:
      currentImg = max(0, currentImg-1);
      loadImg();
      break;
    case RIGHT:
      currentImg = min(imgFileLength-1, currentImg+1);
      loadImg();
      break;
  }
  switch(key){
    case '1':
      selection = 0;
      break;
    case '2':
      selection = 1;
      break;
    case '3':
      selection = 2;
      break;
  }
  return;
}

PImage loadedImg;
void loadImg(){
  loadedImg = loadImage(imagesToLabelPath + "\\" + assumedValidImgs[currentImg]);
}

int startingMouseX;
int startingMouseY;
int stage = 0;
void mousePressed(){
  switch(mouseButton){
    case LEFT:
      if(stage == 0){
        startingMouseX = mouseX;
        startingMouseY = mouseY;
        stage = 1;
      }else if(stage == 1){
        // add 
        JSONArray picLabs = labels.getJSONArray(assumedValidImgs[currentImg]);
        if(picLabs == null){
          picLabs = new JSONArray();
        }
        JSONObject ret = new JSONObject();
        ret.setInt("type", selection);
        ret.setInt("startingX", startingMouseX);
        ret.setInt("startingY", startingMouseY);
        ret.setInt("endingX", mouseX);
        ret.setInt("endingY", mouseY);
        picLabs.append(ret);
        
        labels.setJSONArray(assumedValidImgs[currentImg], picLabs);
        
        saveJSONObject(labels, labelJSONPath);
        
        stage = 0;
      }
      break;
    case RIGHT:
      stage = 0;
      break;
  }
}


String[] modeText = {"Red", "Blue", "Mobogoal"};
color[] modeColor = {#FF3300, #006CFF, #72FF00};
void draw(){
  background(255);
  image(loadedImg, 0, 0);
  JSONArray imgLabel = labels.getJSONArray(assumedValidImgs[currentImg]);
  if(imgLabel == null){
    imgLabel = new JSONArray();
  }
  for(int i = 0; i < imgLabel.size(); i++){
    JSONObject label = imgLabel.getJSONObject(i);
    strokeWeight(4);
    stroke(modeColor[label.getInt("type")]);
    noFill();
    rect(
      label.getInt("startingX"),
      label.getInt("startingY"),
      label.getInt("endingX") - label.getInt("startingX"),
      label.getInt("endingY") - label.getInt("startingY")
    );
  }
  if(stage == 1){
    
    strokeWeight(4);
    stroke(#FF8000);
    noFill();
    rect(startingMouseX, startingMouseY, mouseX - startingMouseX, mouseY - startingMouseY);
    
    strokeWeight(2);
    fill(0);
    stroke(0);
    text(modeText[selection], (mouseX + startingMouseX) / 2, max(mouseY, startingMouseY));
  }
}
