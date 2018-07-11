require! '..': {Signal}
require! '../deps': {sleep}

lim = 100000
startup-delay = 1000ms
max-jitter = (lim * 7 / 1000) + 20ms
console.log "Max jitter is: ", max-jitter

signals = [(new Signal) for til lim]
test-failed = no
do
    i = 0
    <~ sleep startup-delay
    <~ :lo(op) ~>
        #signals[i].log.log "waiting for signal #{i}"
        err, res, date <~ signals[i].wait
        if err or (res isnt "this is #{i}") or (date + startup-delay + max-jitter < Date.now!)
            test-failed := yes
            console.log "diff: ", Date.now! - date
            console.log "...got signal response for #{i} err: ", err, "res: ", res
        i++
        return op! if i is lim
        lo(op)

    if test-failed
        throw "Test failed."
    else
        console.log "Succeeded test."


do
    for let x til lim
        #signals[x].log.log "running signal #{x}"
        signals[x].go null, "this is #{x}", Date.now!
