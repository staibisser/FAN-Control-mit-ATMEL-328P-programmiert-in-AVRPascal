# 🔥 FanControl – Lüfter- und Schiebersteuerung

Kompakte Embedded-Steuerung für Lüfter und Abgasschieber eines Gasdurchlauferhitzers.  
Das Projekt kombiniert eigene Hardware (KiCad) mit Firmware in **AVRPascal** auf einem ATmega328PB.

Ziel ist ein durchgängiges Beispiel von:  
**Elektronik → Firmware → reale Anwendung**

---

## 🚀 Features

- 🌡️ Temperaturmessung mit **DS18B20 (1-Wire)**
- 🔍 Erkennung des Gerätezustands (Analogsignal)
- 🔄 Motorsteuerung für Abgasschieber (Auf / Zu)
- 🌬️ Lüftersteuerung abhängig von Temperatur
- ⚡ Betrieb mit **24 V DC**
- 📦 Kompakte Bauform für **DIN-Schienenmontage**

---

## 🧱 Systemübersicht

### Hardware

- **MCU:** ATmega328PB  
- **Temperatursensor:** DS18B20  
- **Motortreiber:** DRV8871DDA  
- **Lüftersteuerung:** MOSFET AO3400A  
- **Signalaufbereitung:** LM358  
- **Versorgung:** 24 V DC  
- **Gehäuse:** Bernic Series 350 (DIN-Schiene)  

Entwickelt mit **KiCad**

---

### Software

- Sprache: **AVRPascal**
- Funktionen:
  - Temperaturmessung
  - Zustandsanalyse des Durchlauferhitzers
  - Steuerung des Abgasschiebers
  - Temperaturabhängige Lüfterregelung

---

## 📁 Projektstruktur

```
FanControl/
├── Hardware/     # KiCad Projekt (Schaltplan + Layout)
├── Software/     # AVRPascal Firmware
└── README.md
```

---

## ⚙️ Voraussetzungen

### Hardware
- ATmega328PB
- Programmer (z. B. USBasp)

### Software
- Free Pascal / AVRPascal
- KiCad (optional für Hardware-Anpassung)

---

## 🔧 Build & Flash

Firmware kompilieren und mit `avrdude` flashen:

```bash
avrdude -c usbasp -p m328p -P usb -U flash:w:firmware.hex
```

### Fuse-Einstellungen (Beispiel)

- Takt: externer 16 MHz Quarz
- Brown-out: optional deaktiviert

> Fuse-Werte müssen zur Hardware passen

---

## ⚠️ Sicherheitshinweis

Dieses Projekt ist **keine zertifizierte Steuerung**.

Einsatz auf eigene Verantwortung, insbesondere bei:
- Gasgeräten
- hohen Temperaturen
- sicherheitsrelevanten Funktionen

Keine Garantie für Normen oder Zulassungen.

---

## 🎯 Ziel des Projekts

- Demonstration einer kompletten Embedded-Lösung  
- Kombination von **KiCad + AVRPascal**  
- Praxisnahes Beispiel für Steuerungstechnik  

---

## 📄 Lizenz

MIT License

---

## 👨‍💻 Autor

Christof Biner
