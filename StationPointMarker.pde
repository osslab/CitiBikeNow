import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.marker.SimplePointMarker;
 
 
 
public class StationPointMarker extends SimplePointMarker {
 
 
  
  public StationPointMarker(Location location) {
    super(location);
  }
 
   public StationPointMarker(Location location, HashMap<String, Object> properties) {
    super(location, properties);

  }
 
  public void draw(PGraphics pg, float x, float y) {
    

    pg.pushStyle();
    pg.noStroke();
    int availableBikes = (Integer) properties.get("availableBikes");
    
    if(availableBikes<5)pg.fill(255, 201, 33, 100*(1+1.5*(5-availableBikes)/5));
    else if (availableBikes>=5 && availableBikes<20) pg.fill(36,234,153, 100*(1+((availableBikes%10)*0.1)));
    else if (availableBikes >= 20) pg.fill(131,39,129, 100*(1+((availableBikes%10)*0.1)));
    pg.ellipse(x, y, 18+availableBikes*0.8,18+availableBikes*0.8);
    pg.textSize(14);
    pg.fill(255, 255, 255, 255);
    pg.text(properties.get("availableBikes").toString(), x-textWidth(properties.get("availableBikes").toString())/2, y+6);
    
    
    pg.popStyle();
  }
}
