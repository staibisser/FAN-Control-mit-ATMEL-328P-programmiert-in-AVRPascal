unit ds18b20;

{
  Author  : Christof Biner
  License : MIT (siehe LICENSE Datei im Repository)
}

{$MODE objfpc}

interface

type
  TSensorError = (
    seNone,          // kein Fehler
    seNoSensor,      // Sensor nicht erkannt
    seCRCError,      // CRC ungültig
    seOutOfRange     // Temperatur außerhalb gültigem Bereich
  );

  TDS18B20 = object
  private
    _pin: byte;

    // GPIO-Bitbanging
    procedure digitalWriteLow(pin: byte);
    procedure digitalWriteHighZ(pin: byte);
    function digitalRead(pin: byte): boolean;

    // 1-Wire Protokoll
    function Reset: boolean;
    procedure WriteByte(b: byte);
    function ReadByte: byte;
    function ReadScratchpad(out tempCents: smallint; out err: TSensorError): boolean;

  public
    procedure Init(pin: byte);
    function ReadTemperature(out tempCents: integer; out err: TSensorError): boolean;
  end;

implementation

uses
  defs, timer;

function CRC8_Dallas(const data: array of byte; len: byte): byte;
var
  i, j: byte;
  crc: byte = 0;
begin
  for i := 0 to len - 1 do
  begin
    crc := crc xor data[i];
    for j := 0 to 7 do
    begin
      if (crc and $01) <> 0 then
        crc := (crc shr 1) xor $8C
      else
        crc := crc shr 1;
    end;
  end;
  Result := crc;
end;

procedure TDS18B20.digitalWriteLow(pin: byte);
begin
  DDRD := DDRD or (1 shl pin);
  PORTD := PORTD and not (1 shl pin);
end;

procedure TDS18B20.digitalWriteHighZ(pin: byte);
begin
  DDRD := DDRD and not (1 shl pin);
  PORTD := PORTD and not (1 shl pin);
end;

function TDS18B20.digitalRead(pin: byte): boolean;
begin
  Result := (PIND and (1 shl pin)) <> 0;
end;

procedure TDS18B20.Init(pin: byte);
begin
  _pin := pin;
  digitalWriteHighZ(_pin);
end;

function TDS18B20.Reset: boolean;
begin
  digitalWriteLow(_pin);
  DelayMicroseconds(480);
  digitalWriteHighZ(_pin);
  DelayMicroseconds(70);
  Result := not digitalRead(_pin); // Präsenzsignal prüfen
  DelayMicroseconds(410);
end;

procedure TDS18B20.WriteByte(b: byte);
var
  i: byte;
begin
  for i := 0 to 7 do
  begin
    digitalWriteLow(_pin);
    if (b and (1 shl i)) <> 0 then
    begin
      DelayMicroseconds(10);
      digitalWriteHighZ(_pin);
      DelayMicroseconds(55);
    end
    else
    begin
      DelayMicroseconds(65);
      digitalWriteHighZ(_pin);
      DelayMicroseconds(5);
    end;
  end;
end;

function TDS18B20.ReadByte: byte;
var
  i: byte;
begin
  Result := 0;
  for i := 0 to 7 do
  begin
    digitalWriteLow(_pin);
    DelayMicroseconds(3);
    digitalWriteHighZ(_pin);
    DelayMicroseconds(10);
    if digitalRead(_pin) then
      Result := Result or (1 shl i);
    DelayMicroseconds(53);
  end;
end;

function TDS18B20.ReadScratchpad(out tempCents: smallint; out err: TSensorError): boolean;
var
  data: array[0..8] of byte;
  i: byte;
  raw: smallint;
  calc: longint;
begin
  err := seNone;

  if not Reset then
  begin
    err := seNoSensor;
    exit(false);
  end;

  WriteByte($CC);
  WriteByte($44);
  Delay(750);

  if not Reset then
  begin
    err := seNoSensor;
    exit(false);
  end;

  WriteByte($CC);
  WriteByte($BE);
  for i := 0 to 8 do
    data[i] := ReadByte;

  if CRC8_Dallas(data, 8) <> data[8] then
  begin
    err := seCRCError;
    exit(false);
  end;

  raw := smallint(word(data[1]) shl 8 or word(data[0]));
  calc := (longint(raw) * 100) div 16;

  if (calc < -5500) or (calc > 12500) then
  begin
    err := seOutOfRange;
    exit(false);
  end;

  tempCents := calc;
  Result := true;
end;

function TDS18B20.ReadTemperature(out tempCents: integer; out err: TSensorError): boolean;
begin
  Result := ReadScratchpad(tempCents, err);
end;

end.

