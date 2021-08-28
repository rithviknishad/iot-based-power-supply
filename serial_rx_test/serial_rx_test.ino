void setup() {
  Serial.begin(115200);
}

float x = 0.1;

void loop() {
  delay(10);
  writeToMatlab(sin(x += 0.01));
}

void writeToMatlab(float value) {
  byte *b = (byte *) &value;
  Serial.write(b, 4);
  Serial.write(13);
  Serial.write(10);
}
