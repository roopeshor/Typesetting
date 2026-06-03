#counter(heading).update(0)
#set heading(numbering: "A.1")
#set page(margin: (left: 1.2in, right: 1in, top: 1.4in, bottom: 1in))
= Appendices <unnumbered>
#v(-1cm)
== Transmitter Program
#v(-7pt)
#set text(size: 11pt)
#set par(leading: .4em)
```cpp
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#define MAX_PATH_SIZE 27
// node ID is never 0
#define DEST_NODE_ID 5
#define THIS_NODE_ID 1
#define MAX_PACKET_SIZE 32
#define MAX_SEEN_STACK 20
#define BTN_SOS_PIN PB1
#define LED_SOS_SEND PC13
#define LED_SOS_ACK PB8
typedef struct __attribute__((packed)) {
  byte msgID;
  byte msg_type; // 0 - sos, 1 - ack
  byte ttl;
  byte src;
  byte dest;
  byte path[MAX_PATH_SIZE];
s } Packet;
// Radio Pins: CE = PB0, CSN = PA4
RF24 radio(PB0, PA4);
const uint64_t address = 0xF0F0F0F0E1LL;
byte seenTxrStack[MAX_SEEN_STACK] = { 0 };
byte seenMsgIDStack[MAX_SEEN_STACK] = { 0 };
int seenStackTop = -1;
byte msgID = 1;
Packet pkt;
byte waitingForACK = 0;
long lastSOS_Sent;
void setup() {
  Serial.begin(9600);
  pinMode(BTN_SOS_PIN, INPUT_PULLUP);
  pinMode(LED_SOS_SEND, OUTPUT);
  pinMode(LED_SOS_ACK, OUTPUT);
  digitalWrite(LED_SOS_SEND, HIGH);
  if (!radio.begin()) {
    Serial.println("Radio hardware not responding!");
    while (1) ;
  }
  radio.openWritingPipe(address);
  radio.openReadingPipe(0, address);
  radio.setPALevel(RF24_PA_MIN);
  radio.startListening();
  Serial.println("Transmitter ready");
}
void loop() {
  if (digitalRead(BTN_SOS_PIN) == LOW && waitingForACK == 0) {
    digitalWrite(LED_SOS_SEND, LOW);
    // Build pkt
    memset(&pkt, 0, sizeof(Packet));
    pkt.msgID = msgID;
    pkt.msg_type = 0;
    pkt.ttl = 10;             // TTL
    pkt.src = THIS_NODE_ID;   // Src node ID
    pkt.dest = DEST_NODE_ID;  // destination node ID
    Serial.print("Sending SOS to Dest: ");
    Serial.println(DEST_NODE_ID);
    transmit(&pkt, sizeof(Packet));
    waitingForACK = 1;
    lastSOS_Sent = millis();
    msgID++;
    delay(500);
  } else if (waitingForACK == 1 && radio.available()) {
    memset(&pkt, 0, sizeof(Packet));
    radio.read(&pkt, sizeof(Packet));
    if (pkt.msg_type != 1) return;
    if (pkt.path[0] == 0 && pkt.dest == THIS_NODE_ID) {
      Serial.println("direct connection");
      // return;
    }
    for (int j = 0; j < MAX_SEEN_STACK; j++) {
      if (seenTxrStack[j] == pkt.src && seenMsgIDStack[j] == pkt.msgID) {
        // ignore
        Serial.print("src: ");
        Serial.print(pkt.src);
        Serial.print(", msgID: ");
        Serial.print(pkt.msgID);
        Serial.println(" Alredy seen");
        return;
      }
    }
    int i = pathStackTop(pkt);  // no of nodes in path.
    // Destination reached
    if (pkt.dest == THIS_NODE_ID) {
      Serial.println("\nSOS ACK Received");
      digitalWrite(LED_SOS_ACK, HIGH);
      waitingForACK = 0;
      digitalWrite(LED_SOS_SEND, HIGH);
      delay(1000);
      digitalWrite(LED_SOS_ACK, LOW);
      
      markAsSeen(pkt);
      return ;
    }
    if (pkt.ttl <= 0) {
      markAsSeen(pkt);
      return;
    }
  } else if (waitingForACK == 1 && millis() - lastSOS_Sent > 3000) {
    waitingForACK = 0;
    digitalWrite(LED_SOS_SEND, HIGH);
  }
}
void transmit(const void* data, uint8_t len) {
  radio.stopListening();
  radio.write(data, len);
  radio.startListening();
}
int pathStackTop(Packet pkt) {
  char printBuff[50];
  snprintf(printBuff, sizeof(printBuff),
           "Packet:: ID: %d, Type: %d, src: %d, dest: %d, path: ",
           pkt.msgID, pkt.msg_type, pkt.src, pkt.dest);
  Serial.print(printBuff);
  int i = -1;
  while (i < MAX_PATH_SIZE) {
    i++;
    if (pkt.path[i] == 0) break;
    Serial.print(pkt.path[i]);
  }
  Serial.println();
  return i;
}
void markAsSeen(Packet pkt) {
  seenStackTop = (seenStackTop + 1) % MAX_SEEN_STACK;
  seenTxrStack[seenStackTop] = pkt.src;
  seenMsgIDStack[seenStackTop] = pkt.msgID;
}
```
#v(-.5cm)
== Receiver Program
#v(-7pt)
```cpp
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#define MAX_PATH_SIZE 27
#define DEBUG true
#define THIS_NODE_ID 5
#define MAX_PACKET_SIZE 32
#define MAX_SEEN_STACK 20
#define LED_SEND PC13
#define LED_RX PB11
typedef struct __attribute__((packed)) {
  byte msgID;
  byte msg_type;
  byte ttl;
  byte src;
  byte dest;
  byte path[MAX_PATH_SIZE];
} Packet;
// Radio Pins: CE = PB0, CSN = PA4
RF24 radio(PB0, PA4);
const uint64_t address = 0xF0F0F0F0E1LL;
Packet pkt;
byte seenTxrStack[MAX_SEEN_STACK] = { 0 };
byte seenMsgIDStack[MAX_SEEN_STACK] = { 0 };
int seenStackTop = -1;
byte msgID = 1;
void setup() {
  Serial.begin(9600);
  pinMode(LED_RX, OUTPUT);
  pinMode(LED_SEND, OUTPUT);
  if (!radio.begin()) {
    while (1) {
      Serial.println("Radio hardware not responding!");
      delay(100);
    }
  }
  radio.openReadingPipe(0, address);
  radio.openWritingPipe(address);
  radio.setPALevel(RF24_PA_MIN);
  radio.startListening();
  Serial.print("Node started. ID = ");
  Serial.println(THIS_NODE_ID);
}
void loop() {
  if (radio.available()) {
    memset(&pkt, 0, sizeof(Packet));
    radio.read(&pkt, sizeof(Packet));
    for (int j = 0; j < MAX_SEEN_STACK; j++) {
      if (pkt.path[j] == THIS_NODE_ID) {
        // ignore
        Serial.print("src: ");
        Serial.print(pkt.src);
        Serial.print(", msgID: ");
        Serial.print(pkt.msgID);
        Serial.println(" Alredy seen");
        return;
      }
    }
    int i = pathStackTop(pkt);  // no of nodes in path.
    // Destination reached
    if (pkt.dest == THIS_NODE_ID) {
      Serial.print("\nSOS Received: Nearest node ID: ");
      Serial.println(pkt.path[0]);
      digitalWrite(LED_RX, HIGH);
      delay(1000);
      digitalWrite(LED_RX, LOW);
      markAsSeen(pkt);
      Serial.println("sending ACK");
      Packet pk2;
      memset(&pk2, 0, sizeof(Packet));
      pk2.msgID = msgID;
      msgID++;
      pk2.msg_type = 1;  // ACK
      pk2.ttl = 10;
      pk2.src = THIS_NODE_ID;
      pk2.dest = pkt.src;
      markAsSeen(pk2);
      transmit(&pk2, sizeof(Packet));
      return;
    }
    if (pkt.ttl <= 0) {
      markAsSeen(pkt);
      Serial.println("Max hops reached. Dropping pkt.");
      return;
    }
    // Append node ID
    pkt.path[i] = THIS_NODE_ID;
    pkt.ttl = pkt.ttl - 1;
    Serial.println(pkt.path[0]);
    Serial.println("Forwarding pkt...");
    pathStackTop(pkt);
    transmit(&pkt, sizeof(Packet));
    Serial.println("------------");
  }
}
int pathStackTop(Packet pkt) {
  char printBuff[50];
  snprintf(printBuff, sizeof(printBuff),
           "Packet:: ID: %d, Type: %d, src: %d, dest: %d, path: ",
           pkt.msgID, pkt.msg_type, pkt.src, pkt.dest);
  Serial.print(printBuff);
  int i = -1;
  while (i < MAX_PATH_SIZE) {
    i++;
    if (pkt.path[i] == 0) break;
    Serial.print(pkt.path[i]);
  }
  Serial.println();
  return i;
}
void markAsSeen(Packet pkt) {
  seenStackTop = (seenStackTop + 1) % MAX_SEEN_STACK;
  seenTxrStack[seenStackTop] = pkt.src;
  seenMsgIDStack[seenStackTop] = pkt.msgID;
}
void transmit(const void* data, uint8_t len) {
  radio.stopListening();
  digitalWrite(LED_SEND, LOW);
  radio.write(data, len);
  radio.startListening();
  delay(200);
  digitalWrite(LED_SEND, HIGH);
}
```