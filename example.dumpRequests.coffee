###
  Pokemon Go(c) MITM node proxy
  by Michael Strassburger <codepoet@cpan.org>

  Logs the data about you which is sent along in each request

  Using https://github.com/laverdet/pcrypt - big thanks!

###

PokemonGoMITM = require './lib/pokemon-go-mitm'
pcrypt = require 'pcrypt'
fs = require 'fs'

timestamp = Date.now()
platFile = "PlatformRequest-#{timestamp}.json"
fullFile = "Full-#{timestamp}.json"
fs.appendFile "#{platFile}", '[\n', 'utf8'
fs.appendFile "#{fullFile}", '[\n', 'utf8'

server = new PokemonGoMITM port: 8081
    .addRequestEnvelopeHandler (data) ->
        encrypted =  @parseProtobuf data.platform_requests[0]?.request_message, 'POGOProtos.Networking.Platform.Requests.SendEncryptedSignatureRequest'
        buffer = pcrypt.decrypt encrypted.encrypted_signature
        decoded = @parseProtobuf buffer, 'POGOProtos.Networking.Envelopes.SignalAgglomUpdates'
        console.log decoded
        fs.appendFile "#{platFile}", JSON.stringify(decoded, null, 4), 'utf8'
        fs.appendFile "#{fullFile}", JSON.stringify(data, null, 4), 'utf8'
        fs.appendFile "#{platFile}", ',\n', 'utf8'
        fs.appendFile "#{fullFile}", ',\n', 'utf8'
        false

fs.appendFile "#{platFile}", '\n]', 'utf8'
fs.appendFile "#{fullFile}", '\n]', 'utf8'
