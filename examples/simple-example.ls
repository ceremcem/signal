require! '../src/signal-branch': {SignalBranch}
require! '../deps': {Logger}

log = new Logger \test
branch = new SignalBranch timeout: 2000ms
for let index, content of <[ hello there foo bar ]>
    timeout = 1000 + index * Math.random! * 1000
    log.log "new branch named #{content} at #{index} with #{timeout}ms timeout"
    s = branch.add {timeout, name: content}
    <~ sleep (timeout - 20)
    log.log "joining branch named: #{index}"
    s.go content
err, signals <~ branch.joined
log.log "all signals are joined. err: ", err
for signals
    console.log "#{..name}: err: ", ..error, "res: ", ..response
