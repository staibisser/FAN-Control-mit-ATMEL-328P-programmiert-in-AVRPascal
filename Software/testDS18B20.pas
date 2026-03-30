program testDS18B20;

{$MODE objfpc}

uses
  defs, timer, hardwareserial, ds18b20;

var
  sensor: TDS18B20;
  tempC: integer;
  err: TSensorError;
  lastGoodTemp: integer = -9999;

procedure ShowTemperature(t: integer);
var
  z, rest: word;
  s: string[10];
begin
  if t < 0 then
  begin
    Serial.WriteChar('-');
    t := -t;
  end;
  z := t div 100;
  rest := t mod 100;
  Str(z, s); Serial.Write(s);
  Serial.Write('.');
  if rest < 10 then Serial.Write('0');
  Str(rest, s); Serial.Write(s);
  Serial.WriteLn(' Grad C');  // ← kein Sonderzeichen
end;

begin
  Serial.Start(9600);
  delay(1000);             // ← neu
  Serial.WriteLn('DS18B20 UART Test');

  sensor.Init(4);

  while true do
  begin
    if sensor.ReadTemperature(tempC, err) then
    begin
      lastGoodTemp := tempC;
      ShowTemperature(tempC);
    end
    else
    begin
      case err of
        seNoSensor : Serial.WriteLn('Fehler: Kein Sensor.');
        seCRCError : Serial.WriteLn('Fehler: CRC-Fehler.');
        seOutOfRange: Serial.WriteLn('Fehler: Ausserhalb Bereich.');
      end;
      if (err = seCRCError) and (lastGoodTemp <> -9999) then
        ShowTemperature(lastGoodTemp);
    end;
    delay(500);
  end;
end.
