Tor DAM
=======


Tor Distributed Announce Mechanism (DAM) is a protocol and tooling for
mapping machines in the Tor network running this software.

The Tor DAM network is imagined to be pseudo-distributed inside the Tor
network itself. Nodes running Tor DAM can use an existing entrypoint and
start announcing themselves to the entry point(s), or they can be their
own and let others announce to themselves. Tor DAM will store all of
these announcements in a storage backend and utilize it to expand the
knowledge of the nodes using this software. Over time the network will
keep expanding and the user will be able to see all other nodes in the
network either by querying the storage backend, or visualizing it with
some kind of software.


Abstract
--------

* Every node has a HTTP API allowing to list other nodes and announce
  new ones.
* They keep propagating to all valid nodes they know.
* Announcing implies the need of knowledge of at least one or two nodes.
  * It is possible to make this random enough once there are at least 6
    nodes in the network.
* A node announces itself to others by sending a JSON-formatted HTTP
  POST request to one or more active node.
  * Once the POST request is received, the node will validate the
    request and return a secret encrypted with the requester's public
    key.
  * The requester will try to decrypt this secret, and return it plain
    back to the node it's announcing to, along with a cryptographic
    signature, so the node can confirm the requester is in actual
    possession of the private key.
* Tor DAM **does not validate** if a node is malicious or not. This is a
  layer that has to be established on top. Tor DAM is just the entry
  point into the network.


Protocol
--------

A node announcing itself has to do a JSON-formatted HTTP POST request to
one or more active nodes with the format explained below.  N.B. The
strings shown in this document might not be valid, but they represent a
correct example.

* `type` reflects the type of the node
* `address` holds the address of the Tor hidden service
* `message` is the message that has to be signed using the private key
  of this same hidden service.
* `signature` is the base64 encoded signature of the above message.
* `secret` is a string that is used for exchanging messages between the
  client and server.


```
{
  "type": "node",
  "address": "22mobp7vrb7a4gt2.onion",
  "message": "I am a DAM node!",
  "signature": "BuB/Dv8E44CLzUX88K2Ab0lUNS9A0GSkHPtrFNNWZMihPMWN0ORhwMZBRnMJ8woPO3wSONBvEvaCXA2hvsVrUJTa+hnevQNyQXCRhdTVVuVXEpjyFzkMamxb6InrGqbsGGkEUqGMSr9aaQ85N02MMrM6T6JuyqSSssFg2xuO+P4=",
  "secret": ""
}
```

Sending this as a POST request to a node will make it ask for the public
key of the given address from a HSDir in the Tor network. It will
retrieve the public key and try to validate the signature that was made.
Validating this, we assume that the requester is in possession of the
private key.

Following up, the node shall generate a cryptographically secure random
string and encrypt it using the before acquired public key. It will then
be encoded using base64 and sent back to the client:


```
{
  "secret": "eP07xSZWlDdK4+AL0WUkIA3OnVTc3sEgu4MUqGr43TUXaJLfAILvWxKihPxytumBmdJ4LC45LsrdDuhmUSmZZMJxxiLmB4Gf3zoWa1DmStdc147VsGpexY05jaJUZlbmG0kkTFdPmdcKNbis5xfRn8Duo1e5bOPj41lIopwiil0="
}
```

The client will try to decode and decrypt this secret, and send it back
to the node to complete its part of the handshake. The POST request this
time will contain the following data:
* `type` reflects the type of the node
* `address` holds the address of the Tor hidden service
* `message` is the decrypted and base64 encoded secret that the server
  had just sent us.
* `signature` is the base64 encoded signature of the above secret.
* `secret` is a copy of `message` here.


```
{
  "type": "node",
  "address": "22mobp7vrb7a4gt2.onion",
  "message": "ZShhYHYsRGNLOTZ6YUwwP3ZXPnxhQiR9UFVWfmk5TG56TEtLb04vMms+OTIrLlQ7aS4rflR3V041RG5Je0tnYw==",
  "signature": "L1N+VEi3T3aZaYksAy1+0UMoYn7B3Gapfk0dJzOUxUtUYVhj84TgfYeDnADNYrt5UK9hN/lCTIhsM6zPO7mSjQI43l3dKvMIikqQDwNey/XaokyPI4/oKrMoGQnu8E8UmHmI1pFvwdO5EQQaKbi90qWNj93KB/NlTwqD9Ir4blY=",
  "secret": "ZShhYHYsRGNLOTZ6YUwwP3ZXPnxhQiR9UFVWfmk5TG56TEtLb04vMms+OTIrLlQ7aS4rflR3V041RG5Je0tnYw=="
}
```

The node will verify the received plain secret against what it has
encrypted to validate. If the comparison yields no errors, we assume
that the requester is actually in possession of the private key. If the
node is not valid in our database, we will complete the handshake by
welcoming the client into the network:


```
{
  "secret": "Welcome to the DAM network!"
}
```

Further on, the node will append useful metadata to the struct.  We will
add the encoded public key, timestamps of when the client was first seen
and last seen, and a field to indicate if the node is valid.  The latter
is not to be handled by Tor DAM, but rather the upper layer, which
actually has consensus handling.

If the node is valid in another node's database, the remote node will
then propagate back all the valid nodes it knows (including itself) back
to the client in a gzipped and base64 encoded JSON struct. The client
will then handle this and update its own database accordingly.
