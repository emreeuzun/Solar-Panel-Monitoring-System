[EN]
# ☀️ Solar Panel Monitoring System (STM32 + ESP32 + LoRa + Flutter)

This system is an embedded system-based IoT project that wirelessly collects data from a solar panel and provides remote access via a mobile application.

---

## 📽 Project Video  
👉 Turkish explanation video: https://drive.google.com/drive/folders/1Ad2_JxWM5KwCkglfHydmpVaXEW6A_ne7?usp=sharing

---

## 🧠 System Overview

- 📟 **STM32**:
  - Measures voltage, current, temperature (AM2315), and humidity
  - Sends data via **LoRa (E32-433MHz)** to ESP32

- 📶 **ESP32**:
  - Receives LoRa data
  - Displays info on LCD
  - Publishes data via MQTT
  - Sends data to ThingSpeak and Flutter mobile app

- 📱 **Flutter Mobile App**:
  - User login with panel ID 
  - View real-time data (voltage, current, temperature, humidity)
  - Remote access support (different Wi-Fi networks)

---

## ⚙️ Hardware Used

- STM32F103C8T6 (Bluepill)
- ESP32 DevKit v1
- LoRa E32-433T
- AM2315 Sensor
- LCD 16x2
- Power resistors and solar panel
- Power source
- resistor, capacitor, diode

---

## 🔐 Software Features

- STM32: Written in C using STM32CubeIDE + HAL
- ESP32: Written in Arduino framework
- Flutter mobile application: Displays real-time data
- MQTT-based communication
- Multi-panel support 

---
[TR]
# ☀️ Güneş Paneli İzleme Sistemi (STM32 + ESP32 + LoRa + Flutter)

Bu sistem, bir güneş panelinden alınan verileri kablosuz olarak toplayan ve mobil uygulama ile uzaktan erişimle sunan gömülü sistem tabanlı bir IoT projesidir.

---

## 📽 Proje Videosu  
👉 Proje demo videosu:  https://drive.google.com/drive/folders/1Ad2_JxWM5KwCkglfHydmpVaXEW6A_ne7?usp=sharing

---

## 🧠 Sistem Özeti

- 📟 **STM32**:
  - Gerilim, akım, sıcaklık (AM2315) ve nem ölçer
  - Verileri **LoRa (E32-433MHz)** ile ESP32’ye gönderir

- 📶 **ESP32**:
  - LoRa ile gelen verileri alır
  - LCD’de gösterir
  - Verileri **MQTT**  ile gönderir
  - **ThingSpeak** platformuna veri yollar
  - **Flutter mobil uygulamasına** veri iletir

- 📱 **Flutter Mobil Uygulama**:
  - Giriş ekranı (panel ID )
  - Gerçek zamanlı veri görüntüleme (voltaj, akım, sıcaklık, nem)
  - Farklı ağlardan erişim 

---

## ⚙️ Donanım Bileşenleri

- STM32F103C8T6 (Bluepill)
- ESP32 DevKit v1
- LoRa E32-433T
- AM2315 sıcaklık-nem sensörü
- LCD 16x2 ekran
- Güneş paneli ve yük direnci
- Dirençler, kapasitörler, diyotlar

---

## 🔐 Yazılım Özellikleri

- STM32: C dili, STM32CubeIDE + HAL kütüphaneleri
- ESP32: Arduino tabanlı C++
- Flutter: Mobil uygulama, grafik destekli arayüz
- MQTT ile veri iletişimi
- Panel ID ile çoklu panel desteği
