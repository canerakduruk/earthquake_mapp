enum MagnitudeType {
  ml('ML'),
  ms('Ms'),
  mb('mb'),
  md('md'),
  mw('Mw'),
  mwp('Mwp');

  const MagnitudeType(this.value);
  final String value;
}

enum OrderBy {
  time('time'),
  timeDesc('timedesc'),
  magnitude('magnitude'),
  magnitudeDesc('magnitudedesc');

  const OrderBy(this.value);
  final String value;
}

enum ResponseFormat {
  json('json'),
  xml('xml'),
  csv('csv'),
  kml('kml'),
  geoJson('geojson');

  const ResponseFormat(this.value);
  final String value;
}
