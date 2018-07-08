# Description

In a process flow, a condition may need to wait for an external signal from another
function's callback, from another process or from another network device.

```ls

button-press = new Signal

queue.on-receive = (msg) ->
    button-press.go null, msg.data.index

...

do-something!
do-something-else!
err, button-num <~ button-press.wait
console.log "Button number #{button-num} is pressed!"

```    

# Signal

```ls
signal = new Signal

signal.wait [timeout], callback(err, ...args)

    Waits for `signal.go` to call the `callback`.

signal.go err, ...args
```

# SignalBranch

When `.joined`, returns overall `error` and branch `signals`

```ls
branch = new SignalBranch {timeout?}

signal = branch.add!  # adds a new signal branch
...

err, signals <~ branch.joined

    where:  err is the error either set by SignalBranch's timeout or any
            of signals (timeout or by .go method's err parameter)
```
