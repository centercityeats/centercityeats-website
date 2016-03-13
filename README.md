## centercityeats

This is the source and data for [Center City Eats](http://centercityeats.com). At the moment, there is no automated deployment mechanism, all manual.

The source was 100% based on the Mapbox Example ['Build a store locator'](https://www.mapbox.com/help/building-a-store-locator/). To date, only slight modications for labels and displaying additional restaurant field  data have been made.

Note: The mapbox token has been removed.

```
site/index.html - The main web page
site/marker.png - Custom map marker used by Mapbox example
site/centercityeats.geocodejson - The geocodejson data file containing the restaurants

tools/geocodejson.rb - A tool for taking a geocodejson file and adding geometry entries where missing.

Usage: ruby geocodejson.rb <mapquest api token for geocoding> <geocodejson file with missing geolocation geometry entries> <output geocodejson file with geolocation entries>
```

### Data (geocodejson)

At the minimum, all geocode json entries must have properties for restaurantName and all address (address, city, country, postalCode, state) fields. To display properly on the map, there needs to be a geometry entry with lat/lon. 

The geocodejson.rb tool faciliates generating geometry entries. Alternatively, free web-based tools like the [MyGeoPosition.com](http://mygeoposition.com/) website can be used to get the lat/lon for the geometry entry.

Example of geocodejson type 'Feature' entry. 'Feature' is the type for the geocodejson data that contains each of the restaurant listings.

```
{
  "type": "Feature",
  "properties": {
    "restaurantName": "Au Bon Pain (Various)",
    "phoneFormatted": "(215) 564-9705",
    "phone": "215649705",
    "address": "2005 Market Street",
    "city": "Philadelphia",
    "country": "United States",
    "postalCode": "19103",
    "state": "PA",
    "restaurantDescription": "'Good for soup. Relatively inexpensive and relatively low on calories. Pretty delicious'",
    "restaurantHours": "M-FR 6:00AM-5:00PM, SA/SU (CL)",
    "restaurantWebsite": "http://aubonpain.com/"
  },
  "geometry": {
    "type": "Point",
    "coordinates": [
      -75.1733830612245,
      39.9536787959184
    ]
  }
}
```
