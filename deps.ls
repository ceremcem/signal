try 
    require! '../../lib': {sleep, Logger}
catch 
    sleep = (ms, f) -> set-timeout f, ms
    get-formatted-date = -> 
        d = new Date 
        "#{d.getFullYear!}-#{d.getMonth! + 1}-#{d.getDate!} #{d.getHours!}:#{d.getMinutes!}:#{d.getSeconds!}.#{d.getMilliseconds!}"

    class Logger
        (@name) -> 

        log: ->
            console.log ...['[', getFormattedDate(), ']', "#{@name}:", ...arguments]

module.exports = {
    sleep, Logger
}
