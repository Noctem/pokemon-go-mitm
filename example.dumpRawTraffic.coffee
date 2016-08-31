###
  Pokemon Go(c) MITM node proxy
  by Michael Strassburger <codepoet@cpan.org>

  This example dumps all raw envelopes and signatures to separate files

###

PokemonGoMITM = require './lib/pokemon-go-mitm'
fs = require 'fs'
pcrypt = require 'pcrypt'

server = new PokemonGoMITM port: 8081, debug: true
	.addRawRequestEnvelopeHandler (buffer) ->
		timestamp = Date.now()
		if decoded = @parseProtobuf buffer, 'POGOProtos.Networking.Envelopes.RequestEnvelope'
			id = decoded.request_id
		console.log "[#] Request Envelope", decoded
		fs.writeFileSync "#{timestamp}.#{id}.request", buffer, 'binary'

		return false unless decoded.platform_requests[0]?.request_message

		encrypted = @parseProtobuf decoded.platform_requests[0]?.request_message, 'POGOProtos.Networking.Platform.Requests.SendEncryptedSignatureRequest'
		buffer = pcrypt.decrypt encrypted.encrypted_signature
		decoded = @parseProtobuf buffer, 'POGOProtos.Networking.Envelopes.SignalAgglomUpdates'
		console.log "[@] Request Envelope Signature", decoded
		fs.writeFileSync "#{timestamp}.#{id}.signature", buffer, 'binary'
		false

	.addRawResponseEnvelopeHandler (buffer) ->
		timestamp = Date.now()
		if decoded = @parseProtobuf buffer, 'POGOProtos.Networking.Envelopes.ResponseEnvelope'
			id = decoded.request_id
		console.log "[#] Response Envelope", decoded
		fs.writeFileSync "#{timestamp}.#{id}.response", buffer, 'binary'
		false

