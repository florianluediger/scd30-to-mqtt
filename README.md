# SCD30 to MQTT with Toit

This Toit application reads values from the SCD30 Co2 sensor via I2C and publishes them via MQTT to a broker. In my example, I have used AWS IoT Core for that.

To test this app on your ESP32, you need to edit the properties and certificates for your MQTT broker and follow the instructions in [toitlang/jaguar](https://github.com/toitlang/jaguar#how-do-i-use-it).