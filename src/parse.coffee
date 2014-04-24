ber = require './ber'

module.exports = parse =
    ###
    Parse is a low-level utility parsing response and tuples.
    ###
    
    response: (body) ->
        count = body.readUInt32LE 4
        # maybe there is only count
        return count if body.length is 8

        bytesRead = 8
        tuples = []
        
        while count > 0
            size = body.readUInt32LE bytesRead
            bytesRead += 4
            tuple = body.slice bytesRead, bytesRead += size + 4
            # can you see the hack? here it is      ^^
            tuples.push parse.tuple tuple
            count--
        
        return tuples
    
    tuple: (tuple) ->
        count = tuple.readUInt32LE 0 # cardinality
        bytesRead = 4
        fields = []
        
        while count > 0
            sizeBer = ber.decode tuple, bytesRead
            bytesRead = sizeBer.nextIndex
            size = sizeBer.value
            fields.push tuple.slice bytesRead, bytesRead += size
            count--
        
        return fields
