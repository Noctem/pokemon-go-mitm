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

    .addRawRequestEnvelopeHandler (buffer) ->
        try
            timestamp = Date.now()
            if decoded = @parseProtobuf buffer, 'POGOProtos.Networking.Envelopes.RequestEnvelope'
                id = decoded.request_id
            fs.writeFileSync "#{timestamp}-#{id}.request", buffer, 'binary'

            return false unless decoded.platform_requests

            for plat in decoded.platform_requests
                encrypted = @parseProtobuf plat.request_message, 'POGOProtos.Networking.Platform.Requests.SendEncryptedSignatureRequest'
                console.log encrypted.encrypted_signature
                buffer = pcrypt.decrypt encrypted.encrypted_signature
                console.log pcrypt.decrypt buffer
                fs.writeFileSync "dumps/raw/iOS-#{timestamp}-#{id}.signature", buffer, 'binary'
            false
        catch error
            console.log "Error: #{error}"
            false

fs.appendFile "#{platFile}", '\n]', 'utf8'
fs.appendFile "#{fullFile}", '\n]', 'utf8'
