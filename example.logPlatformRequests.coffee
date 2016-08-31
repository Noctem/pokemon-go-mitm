###
  Pokemon Go(c) MITM node proxy
  by Michael Strassburger <codepoet@cpan.org>

  Logs the data about you which is sent along in each request

  Using https://github.com/laverdet/pcrypt - big thanks!

###

PokemonGoMITM = require './lib/pokemon-go-mitm'
pcrypt = require 'pcrypt'
fs = require 'fs'

server = new PokemonGoMITM port: 8081
    .addRequestEnvelopeHandler (data) ->
        encrypted =  @parseProtobuf data.platform_requests[0]?.request_message, 'POGOProtos.Networking.Platform.Requests.SendEncryptedSignatureRequest'
        buffer = pcrypt.decrypt encrypted.encrypted_signature
        decoded = @parseProtobuf buffer, 'POGOProtos.Networking.Envelopes.SignalAgglomUpdates'
        console.log decoded
        false
