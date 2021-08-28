#include <ESP8266WiFi.h>
#include <ESPAsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <AsyncElegantOTA.h>
#include <ArduinoJson.h>
#include "FS.h"
#include <LittleFS.h>

const char *configFilePath = "/config.json";

StaticJsonDocument<200> config;

AsyncWebServer server(80);

void setup()
{
    // Initialize serial port
    Serial.begin(115200);
    Serial.println();

    if (LittleFS.begin())
    {
        Serial.println(F("Successfully mounted file system"));
    }
    else
    {
        Serial.println(F("Failed to mount file system"));
        return;
    }

    if (!saveConfig())
    {
        Serial.println("Failed to save config");
    }
    else
    {
        Serial.println("Config saved");
    }

    if (!loadConfig(configFilePath))
    {
        Serial.printf("\033[31;1;4m✗ Failed to load configuration from '%s'\n\033[0m", configFilePath);
        return;
    }
    else
    {
        Serial.printf("Successfully loaded configuration from '%s'.\n");
    }

    // // WiFi mode: STA
    // WiFi.mode(WIFI_STA);

    // const char *ssid = config["WIFI_STA_SSID"];

    // WiFi.begin(ssid, config["WIFI_STA_KEY"]);

    // // I/O Blocking: Wait for connection
    // while (WiFi.status() != WL_CONNECTED)
    // {
    //     delay(500);
    //     Serial.printf(".");
    // }

    // Serial.printf("\nConnected to AP: '%s' (%s)\n", ssid, WiFi.localIP().toString());

    // server.on("/", HTTP_GET, [](AsyncWebServerRequest *request)
    //           { request->send(200, "text/plain", "Yes, Power Supply is working..."); });

    // // Start ElegantOTA
    // AsyncElegantOTA.begin(&server);
    // server.begin();

    // Serial.printf("http server started.\n");
}

void loop()
{
}

bool loadConfig(const char *path)
{
    File configFile = LittleFS.open("/config.json", "r");
    if (!configFile)
    {
        Serial.println("Failed to open config file");
        return false;
    }

    size_t size = configFile.size();
    if (size > 1024)
    {
        Serial.println("Config file size is too large");
        return false;
    }

    // Allocate a buffer to store contents of the file.
    std::unique_ptr<char[]> buf(new char[size]);

    // We don't use String here because ArduinoJson library requires the input
    // buffer to be mutable. If you don't use ArduinoJson, you may as well
    // use configFile.readString instead.
    configFile.readBytes(buf.get(), size);

    StaticJsonDocument<200> doc;
    auto error = deserializeJson(doc, buf.get());
    if (error)
    {
        Serial.println("Failed to parse config file");
        return false;
    }

    const char *serverName = doc["WIFI_STA_SSID"];
    const char *accessToken = doc["WIFI_STA_KEY"];

    // Real world application would store these values in some variables for
    // later use.

    Serial.print("Loaded serverName: ");
    Serial.println(serverName);
    Serial.print("Loaded accessToken: ");
    Serial.println(accessToken);
    return true;
    // File configFile = LittleFS.open(path, "r");

    // if (!configFile)
    // {
    //     return false;
    // }

    // size_t size = configFile.size();
    // if (size > 1024)
    // {
    //     Serial.printf("Configuration file '%s' is too large.\n", path);
    //     return false;
    // }
    // else
    // {
    //     Serial.printf("Configuration file found at: '%s' (%d bytes)\n", path, size);
    // }

    // std::unique_ptr<char[]> buf(new char[size]);

    // configFile.readBytes(buf.get(), size);

    // configFile.close();

    // auto error = deserializeJson(config, buf.get());

    // if (error)
    // {
    //     Serial.printf("error parsing json file: '%s'\n", path);
    //     return false;
    // }

    // return true;
}

bool saveConfig()
{
    StaticJsonDocument<200> doc;
    doc["WIFI_STA_SSID"] = "SUNDALE BSNL FTTH";
    doc["WIFI_STA_KEY"] = "sundale6128";

    File configFile = LittleFS.open("/config.json", "w");
    if (!configFile)
    {
        Serial.println("Failed to open config file for writing");
        return false;
    }

    serializeJson(doc, configFile);
    return true;
}