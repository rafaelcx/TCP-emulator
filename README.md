# TCP Emulator

In this repo, you'll find the sending and receiving transport-level code for implementing a simple and reliable Alternating-Bit data transfer protocol.

## Overview

The procedures we will write are for the sending entity (A) and the receiving entity (B). Only unidirectional transfer of data (from A to B) is required. Of course, the B side will have to send packets to A to acknowledge (positively or negatively) receipt of data. Our routines are to be implemented in the form of the procedures described below. These procedures will be called by (and will call) procedures that the text book author has written which emulate a network environment.

The unit of data passed between the upper layers and our protocols is a message, which is declared as:

```
struct msg {
  char data[20];
};
```

This declaration, and all other data structure and emulator routines, as well as stub routines (i.e., those you are to complete) are in the attached file, prog2.c, described later. Our sending entity will thus receive data in 20-byte chunks from layer5; our receiving entity should deliver 20-byte chunks of correctly received data to layer5 at the receiving side.

The unit of data passed between our routines and the network layer is the packet, which is declared as:

```
struct pkt {
  int seqnum;
  int acknum;
  int checksum;
  char payload[20];
};
```

Our routines will fill in the payload field from the message data passed down from layer5. The other packet fields will be used by our protocols to insure reliable delivery, as we've seen in class.

The routines we will write are detailed below. As noted above, such procedures in real-life would be part of the operating system, and would be called by other procedures in the operating system.

`A_output(message)` where message is a structure of type msg, containing data to be sent to the B-side. This routine will be called whenever the upper layer at the sending side (A) has a message to send. It is the job of our protocol to insure that the data in such a message is delivered in-order, and correctly, to the receiving side upper layer.

`A_input(packet)` where packet is a structure of type pkt. This routine will be called whenever a packet sent from the B-side (i.e., as a result of a tolayer3() being done by a B-side procedure) arrives at the A-side. packet is the (possibly corrupted) packet sent from the B-side.

`A_timerinterrupt()` This routine will be called when A's timer expires (thus generating a timer interrupt). We'll probably want to use this routine to control the retransmission of packets. See starttimer() and stoptimer() below for how the timer is started and stopped.

`A_init()` This routine will be called once, before any of our other A-side routines are called. It can be used to do any required initialization.

`B_input(packet)` where packet is a structure of type pkt. This routine will be called whenever a packet sent from the A-side (i.e., as a result of a tolayer3() being done by a A-side procedure) arrives at the B-side. packet is the (possibly corrupted) packet sent from the A-side.

`B_init()` This routine will be called once, before any of our other B-side routines are called. It can be used to do any required initialization.

## Software Interfaces

The procedures described above are the ones that we will write. The text book author has written the following routines which can be called by our routines:

`starttimer(calling_entity,increment)` where calling_entity is either 0 (for starting the A-side timer) or 1 (for starting the B side timer), and increment is a float value indicating the amount of time that will pass before the timer interrupts. A's timer should only be started (or stopped) by A-side routines, and similarly for the B-side timer. To give we an idea of the appropriate increment value to use: a packet sent into the network takes an average of 5 time units to arrive at the other side when there are no other messages in the medium.

`stoptimer(calling_entity)` where calling_entity is either 0 (for stopping the A-side timer) or 1 (for stopping the B side timer).

`tolayer3(calling_entity,packet)` where calling_entity is either 0 (for the A-side send) or 1 (for the B side send), and packet is a structure of type pkt. Calling this routine will cause the packet to be sent into the network, destined for the other entity.

`tolayer5(calling_entity,message)` where calling_entity is either 0 (for A-side delivery to layer 5) or 1 (for B-side delivery to layer 5), and message is a structure of type msg. With unidirectional data transfer, we would only be calling this with calling_entity equal to 1 (delivery to the B-side). Calling this routine will cause data to be passed up to layer 5.

## The simulated network environment

A call to procedure `tolayer3()` sends packets into the medium (i.e., into the network layer). Oour procedures `A_input()` and `B_input()` are called when a packet is to be delivered from the medium to our protocol layer.

The medium is capable of corrupting and losing packets. It will not reorder packets. When we compile our procedures and the author'sprocedures together and run the resulting program, we will be asked to specify values regarding the simulated network environment:

**Number of messages to simulate**. the author'semulator (and our routines) will stop as soon as this number of messages have been passed down from layer 5, regardless of whether or not all of the messages have been correctly delivered. Thus, we need not worry about undelivered or unACK'ed messages still in our sender when the emulator stops. Note that if we set this value to 1, our program will terminate immediately, before the message is delivered to the other side. Thus, this value should always be greater than 1.

**Loss**. We are asked to specify a packet loss probability. A value of 0.1 would mean that one in ten packets (on average) are lost.
Corruption. We are asked to specify a packet loss probability. A value of 0.2 would mean that one in five packets (on average) are corrupted. Note that the contents of payload, sequence, ack, or checksum fields can be corrupted. We checksum should thus include the data, sequence, and ack fields.

**Tracing**. Setting a tracing value of 1 or 2 will print out useful information about what is going on inside the emulation (e.g., what's happening to packets and timers). A tracing value of 0 will turn this off. A tracing value greater than 2 will display all sorts of odd messages that are for the author'sown emulator-debugging purposes. A tracing value of 2 may be helpful to we in debugging our code. We should keep in mind that real implementors do not have underlying networks that provide such nice information about what is going to happen to their packets!

**Average time between messages from sender's layer5**. We can set this value to any non-zero, positive value. Note that the smaller the value we choose, the faster packets will be be arriving to our sender.

## The Alternating-Bit-Protocol

We are to write the procedures, `A_output()`, `A_input()`, `A_timerinterrupt()`, `A_init()`, `B_input()`, and `B_init()` which together will implement a stop-and-wait (i.e., the alternating bit protocol, which we referred to as rdt3.0 in the text) unidirectional transfer of data from the A-side to the B-side. Our protocol should use both ACK and NACK messages.

We should choose a very large value for the average time between messages from sender's layer5, so that our sender is never called while it still has an outstanding, unacknowledged message it is trying to send to the receiver. I'd suggest we choose a value of 1000. Wou should also perform a check in our sender to make sure that when `A_output()` is called, there is no message currently in transit. If there is, we can simply ignore (drop) the data being passed to the `A_output()` routine.

This project can be completed on any machine supporting C. It makes no use of UNIX features. (We can simply copy the prog2.c file to whatever machine and OS we choose).

We recommend that we should hand in a code listing, a design document, and sample output. For our sample output, our procedures might print out a message whenever an event occurs at our sender or receiver (a message/packet arrival, or a timer interrupt) as well as any action taken in response. We might want to hand in output for a run up to the point (approximately) when 10 messages have been ACK'ed correctly at the receiver, a loss probability of 0.1, and a corruption probability of 0.3, and a trace level of 2. We might want to annotate our printout with a colored pen showing how our protocol correctly recovered from packet loss and corruption.