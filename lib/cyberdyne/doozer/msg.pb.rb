### Generated by rprotoc. DO NOT EDIT!
### <proto file: doozerd/server/msg.proto>
# package server;
#
# // see doc/proto.md
# message Request {
#   optional int32 tag = 1;
#
#   enum Verb {
#       GET      = 1;
#       SET      = 2;
#       DEL      = 3;
#       REV      = 5;
#       WAIT     = 6;
#       NOP      = 7;
#       WALK     = 9;
#       GETDIR   = 14;
#       STAT     = 16;
#       ACCESS   = 99;
#   }
#   optional Verb verb = 2;
#
#   optional string path = 4;
#   optional bytes value = 5;
#   optional int32 other_tag = 6;
#
#   optional int32 offset = 7;
#
#   optional int64 rev = 9;
# }
#
# // see doc/proto.md
# message Response {
#   optional int32 tag = 1;
#   optional int32 flags = 2;
#
#   optional int64 rev = 3;
#   optional string path = 5;
#   optional bytes value = 6;
#   optional int32 len = 8;
#
#   enum Err {
#     // don't use value 0
#     OTHER        = 127;
#     TAG_IN_USE   = 1;
#     UNKNOWN_VERB = 2;
#     READONLY     = 3;
#     TOO_LATE     = 4;
#     REV_MISMATCH = 5;
#     BAD_PATH     = 6;
#     MISSING_ARG  = 7;
#     RANGE        = 8;
#     NOTDIR       = 20;
#     ISDIR        = 21;
#     NOENT        = 22;
#   }
#   optional Err err_code = 100;
#   optional string err_detail = 101;
# }

['message', 'enum', 'service', 'extend'].each{ |file| require "protobug/message/#{file}" }

module Cyberdyne
  module Doozer
    class Request < ::Protobuf::Message
      class Verb < ::Protobuf::Enum
      end
    end
  end
end

