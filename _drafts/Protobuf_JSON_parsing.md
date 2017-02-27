---
layout: post
title: Using Protocol Buffers to parse your JSON
---

proto3 doc: https://developers.google.com/protocol-buffers/docs/proto3
swift-protobuf: https://github.com/apple/swift-protobuf

caveats:
- cannot have a non-optional reference to another message

advantages:
- share a specification using a description file instead of some JSON parsing code handling dictionaries
- you can combine multiple `.proto` file to describe your endpoints
- enables you to migrate to protobuf one endpoint at a time while using the same parsing code