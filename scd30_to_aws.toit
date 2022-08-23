import gpio
import i2c
import scd30
import net
import net.x509
import mqtt
import tls
import ntp
import esp32

measurements/scd30.Measurements := scd30.Measurements 0.0 0.0 0.0

CLIENT_ID := "scd30-client-$(random)"
HOST := "something.iot.eu-central-1.amazonaws.com"
PORT := 8883
TOPIC := "scd30/esp32"

main:
  ntp_result := ntp.synchronize
  if not ntp_result:
    print "Couldn't get current time via NTP"
    exit 1

  esp32.adjust_real_time_clock ntp_result.adjustment

  bus := i2c.Bus
    --sda=gpio.Pin 21
    --scl=gpio.Pin 22

  device := bus.device scd30.Scd30.I2C_ADDRESS
  scd30 := scd30.Scd30 device

  network := net.open
  transport := mqtt.TcpTransport.tls 
    network
    --host=HOST
    --port=PORT
    --root_certificates=[SERVER_CERTIFICATE]
    --certificate=tls.Certificate CLIENT_CERTIFICATE CLIENT_KEY
  
  client := mqtt.Client --transport=transport

  client.start --client_id=CLIENT_ID --on_error=:: print "Client error: $it"

  while true:
    measurements = scd30.read
    
    t := Time.now.utc
    time_string := "$t.year-$(%02d t.month)-$(%02d t.day) $(%02d t.h):$(%02d t.m):$(%02d t.s).000000"
    message := "{\"time\":\"$time_string\",\"co2\":$measurements.co2,\"temperature\":$measurements.temperature,\"humidity\":$measurements.humidity}"

    client.publish TOPIC message.to_byte_array

    sleep --ms=300000


SERVER_CERTIFICATE := x509.Certificate.parse """\
-----BEGIN CERTIFICATE-----
...
MBIGA1UEChMLQmVzdCBDQSBMdGQxNzA1BgNVBAsTLk
...
-----END CERTIFICATE-----
"""

CLIENT_CERTIFICATE := x509.Certificate.parse """\
-----BEGIN CERTIFICATE-----
...
MBIGA1UEChMLQmVzdCBDQSBMdGQxNzA1BgNVBAsTLk
...
-----END CERTIFICATE-----
"""

CLIENT_KEY := """\
-----BEGIN RSA PRIVATE KEY-----
...
MBIGA1UEChMLQmVzdCBDQSBMdGQxNzA1BgNVBAsTLk
...
-----END RSA PRIVATE KEY-----
"""
