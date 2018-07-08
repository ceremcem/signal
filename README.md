![image](https://user-images.githubusercontent.com/6639874/42417478-edd65554-8293-11e8-894d-d1995ac247b2.png)


# Description

This is one of the core libraries used in [ScadaJS](https://github.com/aktos-io/scada.js) for managing events, timeouts and signalling between flow branches.

In a process flow, a condition may need to `.wait` for an external signal from another
function's callback, from another process or from another network device.

```ls

button-press = new Signal

queue.on-receive = (msg) ->
    button-press.go err=null, msg.data.index

...

do-something!
do-something-else!
err, button-num <~ button-press.wait
console.log "Button number #{button-num} is pressed!"

```    

# Signal

```ls
signal = new Signal

signal.wait [timeout], callback(err, ...args)  # Waits for `signal.go` to call the `callback`.

...

signal.go err, ...args
```

# SignalBranch

When `.joined`, returns overall `error` and branch `signals`

```ls
branch = new SignalBranch {timeout?}

for myArray
    signal = branch.add!  # adds a new signal to the branch
    # or with a 1 second timeout: 
    # signal = branch.add 1000ms
    ...
    # do something async here 
    err, res <~ some-async-operation 
    # do something with result
    signal.go err 

err, signals <~ branch.joined
# all async operations are finished at this point.
```
**err** : The error either set by 
* SignalBranch's master timeout or 
* any of branch signals, either by
  * Signal's timeout (defined by `branch.add timeout`) or 
  * by `.go` method's `err` argument
signals: Array of that branch's `Signal` instances where each instance has at least `error` and `response[]` properties.
