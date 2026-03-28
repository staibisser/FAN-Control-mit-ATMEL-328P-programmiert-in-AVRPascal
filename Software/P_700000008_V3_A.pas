program P_700000008_V3_A;

{
  Author  : copyright (c) Christof Biner
  License : MIT (siehe LICENSE Datei im Repository)
}

{$MODE objfpc}

uses
  defs, timer, digital, hardwareserial, ds18b20;

const
  GEonPin = 3; // PD3 Eingang Durchlauferhitzer Gas
  DS18b20Pin = 4; // PD4 wird direkt auf PortD angesprochen!
  IN1Pin = 5; // PD5 INPUT 1 DRV8871DDA Motor Auf
  IN2Pin = 6; // PD6 INPUT 2 DRV8871DDA Motor Zu
  TasterPin = 7; // PD7 Taster für manuell Motor Ein/Aus
  FanPin = 2; // PD2 Lüfter Ein/Aus
  TempFan = 40; // Temp>TempFan ist Lüfter Ein
  Pause = 250; // Millisekunden warten

var
  sensor: TDS18B20;
  tempC: integer;
  err: TSensorError;
  lastGoodTemp: integer;
  GEon: UInt8 = 0;
  IN1: BOOLEAN = FALSE;
  IN2: BOOLEAN = FALSE;
  Taster: BOOLEAN = False;
  Fan: BOOLEAN = FALSE;
  SchieberOnOff: BOOLEAN = FALSE;

function Toggle(b: Boolean): Boolean;
begin
  Result:= not b;
end;

function Motor(befehl: BOOLEAN): BOOLEAN;
begin
  case befehl of
    TRUE:
      begin
        digitalWrite(IN1Pin, HIGH);
        delayMicroseconds(5000);
        digitalWrite(IN2Pin, LOW);
        delayMicroseconds(20000);
        // Lüfter Ein
        digitalWrite(FanPin, HIGH);
      end;
    FALSE:
      begin
        digitalWrite(IN1Pin, LOW);
        delayMicroseconds(5000);
        digitalWrite(IN2Pin, HIGH);
        delayMicroseconds(20000);
         // Lüfter Aus
        digitalWrite(FanPin, LOW);
      end;
  end;
end;

begin
  //Initialisieren
  sensor.Init(DS18b20Pin); // 4 → D4 → PD4
  pinMode(GEonPin, INPUT);
  pinMode(IN1Pin, OUTPUT);
  pinMode(IN2Pin, OUTPUT);
  pinMode(TasterPin, INPUT);
  pinMode(FanPin, OUTPUT);

  // Ausgänge Aus
  Motor(FALSE);

  // ewige Schlaufe
  while true do
  begin

    // Sensoren einlesen
    if sensor.ReadTemperature(tempC, err) then
    begin
      lastGoodTemp:= tempC; // neuer Wert, nur wenn kein Fehler
    end;
    if (DigitalRead(TasterPin) = 1) then
      Taster:= Toggle(Taster);
    GEon:= (DigitalRead(GEonPin)); // Einlesen ob Durchlauferhitzer läuft

    //Bedingungen zum Einschalten
    if ((GEon = 1) or (LastGoodTemp > TempFan) or (Taster)) then
    begin
      SchieberOnOff:= TRUE;
    end;

    //Bedingungen zum Ausschalten
    if ((GEon = 0) and (LastGoodTemp < TempFan) and (not (Taster))) then
    begin
      SchieberOnOff:= False;
    end;

    // Ausgabe Befehle
      SchieberOnOff:= True;
    Motor(SchieberOnOff);

    // Warten/Pause
    Delay(Pause);

    SchieberOnOff:= False;
    Motor(SchieberOnOff);

    // Warten/Pause
    Delay(Pause);


  end;
end.

