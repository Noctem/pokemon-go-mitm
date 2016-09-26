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
fs.writeFileSync "#{platFile}", '[\n', 'utf8'
fs.writeFileSync "#{fullFile}", '[\n', 'utf8'

server = new PokemonGoMITM port: 8081
    .addRequestEnvelopeHandler (data) ->
        try
            fs.appendFileSync "#{fullFile}", JSON.stringify(data, null, '\t'), 'utf8'
            fs.appendFileSync "#{fullFile}", ',\n', 'utf8'

            return false unless data.platform_requests
            for plat in data.platform_requests
                encrypted =  @parseProtobuf plat.request_message, 'POGOProtos.Networking.Platform.Requests.SendEncryptedSignatureRequest'
                buffer = pcrypt.decrypt encrypted.encrypted_signature
                decoded = @parseProtobuf buffer, 'POGOProtos.Networking.Envelopes.SignalAgglomUpdates'
                console.log decoded
                fs.appendFileSync "#{platFile}", JSON.stringify(decoded, null, '\t'), 'utf8'
                fs.appendFileSync "#{platFile}", ',\n', 'utf8'
            false
        catch error
            console.log "Error: #{error}"
            false

fs.appendFile "#{platFile}", '\n]', 'utf8'
fs.appendFile "#{fullFile}", '\n]', 'utf8'
