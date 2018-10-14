require! './signal': {Signal}

export class SignalBranch
    (opts={}) ->
        @timeout = opts.timeout or -1
        @count = 0
        @main = new Signal
        @signals = []
        @error = null
        @branches = []

    cancel: ->
        @main.cancel!
        @main = null
        for i of @signals
            @signals[i].cancel!
            @signals[i] = null

    add: (opts) ->
        timeout = opts?timeout or @timeout
        name = opts?name or "#{@count}"
        #console.log "........signal branch adding: #{name} with timeout #{timeout}"
        signal = new Signal {name}
        @signals.push signal
        @count++
        signal.wait timeout, (err) ~>
            #console.log "==== signal is moving, count: #{@count}"
            if err
                @error = that
            if --@count is 0
                #console.log "+++++letting main go."
                @main.go @error

        return signal

    joined: (callback) ->
        if @count is 0
            @main.go err=null

        @main.wait @timeout, (err) ~>
            for @signals
                if ..error
                    unless err => err = {}
                    err.signals = true
                ..clear!

            callback err, @signals
