/**
 * An application with a basic interactive map. You can zoom and pan the map.
 */


import java.util.List;
import java.util.Arrays;

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;

import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.marker.MarkerManager;
import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import de.fhpotsdam.unfolding.data.Feature;
import de.fhpotsdam.unfolding.data.PointFeature;
import de.fhpotsdam.unfolding.data.GeoJSONReader;
import de.fhpotsdam.unfolding.events.ZoomMapEvent;

boolean record;


PFont BoldFont;
UnfoldingMap map;
MarkerManager markerManager;
StationPointMarker bikeMarker;
List<Marker> bikeMarkers;

PVector rotateCenter = new PVector(350, 250);
Location tischLocation = new Location(40.7294250, -73.9937070);
Location mapTopLeftBoarder;
Location mapBottomRightBorder;


Timer timer;

String executionTime;

File folder;
File[] listOfFiles;

int fileNumber = 0;
int fileTotalNumber = 0;

int currentZoom = 14;


float maxLat;
float minLat;
float maxLon;
float minLon;

PGraphics pg;

void setup() {
  size(displayWidth,displayHeight); // ON SCREEN SIZE
  //pg = createGraphics(4724, 5906); // PRINT SIZE
  
  //folder = new File("/Users/suhongseo/Documents/data-processing/CitiBikeNowPoster/data/con/");
  //listOfFiles = folder.listFiles();
  //fileTotalNumber = listOfFiles.length;

  

  
  setGeoJSON();
  setBikeMarker();


  BoldFont = createFont("Tahoma-Bold", 14);
  textFont(BoldFont);
  
  SimplePointMarker tischMarker = new SimplePointMarker(tischLocation);
 
  
  tischMarker.setColor(color(255, 0, 0, 100));

 
  
  
  map = new UnfoldingMap(this, new StamenMapProvider.Toner());
  map.zoomToLevel(currentZoom);
  map.panTo(tischLocation);  
  
  
  MapUtils.createDefaultEventDispatcher(this, map);
  
  
  
  
  
  
  map.addMarkers(tischMarker);
  map.addMarkers(bikeMarkers);
  
  markerManager = map.getDefaultMarkerManager();
  
  
  mapTopLeftBoarder = map.getTopLeftBorder();
  mapBottomRightBorder = map.getBottomRightBorder();
  
  maxLat = mapTopLeftBoarder.getLat();
  maxLon = mapTopLeftBoarder.getLon();
  minLat = mapBottomRightBorder.getLat();
  minLon = mapBottomRightBorder.getLon();
  
  println(maxLat + ", " + maxLon);
  println(minLat + ", " + minLon);
  
  
  
  
  timer = new Timer(60000); //1min to refresh
  timer.start();  
 
}

void draw() {

  
  
  if (timer.isFinished()) {
    markerManager.clearMarkers();
    setGeoJSON();
    setBikeMarker();
    map.addMarkers(bikeMarkers);

    timer.start();
    println(executionTime);
  } 


    //

  map.draw();
  
  
  textSize(14);
  fill(255,255,255, 255);
  text("Updated Time : ", 10, height-40);
  text(executionTime, 10,height-25);   
 

}

void setGeoJSON(){

  
  String jsonUrl = "";
  jsonUrl = "http://www.citibikenyc.com/stations/json";
  
  
  println(jsonUrl);
  JSONObject jsonObject = loadJSONObject(jsonUrl);
  JSONArray citiBikeJSONArray = jsonObject.getJSONArray("stationBeanList");
  JSONObject geoCitiBikes = new JSONObject(); 
  JSONArray featureList = new JSONArray();
  JSONObject station = new JSONObject();
   
  executionTime =  jsonObject.getString("executionTime");
 

   
  
  for(int i = 0; i < citiBikeJSONArray.size(); i++){
    station = citiBikeJSONArray.getJSONObject(i);
    
    JSONObject point = new JSONObject();
    point.setString("type", "Point");
    
    JSONArray coord = new JSONArray();
    coord.append(station.getFloat("longitude"));
    coord.append(station.getFloat("latitude"));
    
    
    point.setJSONArray("coordinates", coord);
    JSONObject properties = new JSONObject();
    properties.setString("name", station.getString("stationName"));
    properties.setInt("totalDocks", station.getInt("totalDocks"));
    properties.setInt("availableDocks", station.getInt("availableDocks"));
    properties.setInt("availableBikes", station.getInt("availableBikes"));
 
    
    JSONObject feature = new JSONObject();
    
    feature.setJSONObject("geometry", point);
    feature.setJSONObject("properties", properties); 
    feature.setString("type", "Feature");
    featureList.append(feature);
    geoCitiBikes.setJSONArray("features", featureList);
    
  }

   geoCitiBikes.setString("type", "FeatureCollection"); 
   saveJSONObject(geoCitiBikes, "data/new.json");


}

void mousePressed(){
  record = true;

  if (mouseEvent.getClickCount()==2) {
    currentZoom++;
  }
  




  
}
  public void keyPressed() {
    rotateCenter = new PVector(mouseX, mouseY);

    // Inner rotate (i.e. map) works with both, P2D and GLGraphics
    map.mapDisplay.setInnerTransformationCenter(rotateCenter);
    if (key == 'r') {
      map.rotate(-PI / 8);
    } else if (key == 'l') {
      map.rotate(PI / 8);
    }
    else if (key == '-'){
      currentZoom--;
      map.zoomToLevel(currentZoom);
      map.panTo(map.getCenter());
    }
    else if (key == '+'){
      currentZoom++;
      map.zoomToLevel(currentZoom);
      map.panTo(map.getCenter());
    }

  }
  


void setBikeMarker(){

   List<Feature> stations = GeoJSONReader.loadData(this, "data/new.json");
   bikeMarkers = new ArrayList<Marker>();
   bikeMarkers = MapUtils.createSimpleMarkers(stations);
   
   

  for(Feature feature :   stations){
    PointFeature pointFeature = (PointFeature) feature;
    //println(pointFeature.getProperties());
     bikeMarker = new StationPointMarker(pointFeature.getLocation(), pointFeature.getProperties());
    
    
    
    
    //bikeMarker.setColor(color(0, 0, 255, 100));
    //bikeMarker.text(pointFeature.getProperty("name"));
    
    
    bikeMarkers.add(bikeMarker);
    //println(pointFeature.getLocation().toString());
  }  


}


void saveTimestamped(PImage im) { 

 int s = second(); // VALUES FROM 0 - 59

 int mi = minute(); // VALUES FROM 0 - 59

 int h = hour(); // VALUES FROM 0 - 23

 int d = day(); // VALUES FROM 1 - 31

 int m = month(); // VALUES FROM 1 - 12

 int y = year(); // 2003, 2004, 2005, ETC.

 

 String filename = y+"-"+m+"-"+d+"-"+h+"-"+mi+"-"+s+".tiff"; 

 im.save(filename); 

 

}
