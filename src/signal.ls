require! '../deps': {sleep, Logger}
require! 'prelude-ls': {is-it-NaN}

export class Signal
    (opts={}) ->
        if opts.debug
            @debug = yes
        @name = opts.name or arguments.callee.caller.name
        @log = new Logger @name
        @response = []
        @callback = {ctx: null, handler: null}
        if @debug => @log.debug "Initialized new signal."
        @reset!

    reset: ->
        # clear everything like the object is
        # initialized for the first time
        delete @callback.handler
        delete @callback.ctx
        @should-run = no
        @waiting = no
        try clear-timeout @timer
        @timer = void
        @skip-next = no

    fire: (error) ->
        #@log.log "trying to fire..."
        return if typeof! @callback?.handler isnt \Function
        params = unless error then @response else []
        @error = error?.reason
        {handler, ctx} = @callback
        t0 = Date.now!
        err = @error
        @reset!
        set-immediate ~>
            handler.call ctx, err, ...params
            if @debug => @log.debug "...signal has been fired."
            if Date.now! - t0 > 100ms
                @log.warn "System seems busy now? Actual firing took place after #{Date.now! - t0}ms"

    wait: (timeout, callback) ->
        # normalize arguments
        if typeof! timeout is \Function
            callback = timeout
            timeout = 0
        if @waiting
            console.error "We were waiting already. Why hit here?"
            return
        @error = \UNFINISHED

        #if @debug => @log.debug "...adding this callback"
        @callback = {ctx: this, handler: callback}
        @waiting = yes
        unless is-it-NaN timeout
            if timeout > 0
                @timeout = timeout
                if @debug => @log.info "Heartbeating! timeout: #{@timeout}"
                @heartbeat!

        # try to run signal in case of it is let `go` before reaching "wait" line
        if @should-run
            @fire!

    skip-next-go: ->
        @skip-next = yes

    clear: ->
        @should-run = no

    go: (...args) ->
        if @skip-next
            @skip-next = no
            return
        @should-run = yes
        @response = args
        #@log.log "called 'go!'" , @response
        if @waiting
            @fire!

    heartbeat: (duration) ->
        #@log.log "Heartbeating..........."
        if duration > 0
            #@log.log "setting new timeout: #{duration}"
            @timeout = duration
        try clear-timeout @timer
        @timer = sleep @timeout, ~>
            @should-run = yes
            #@log.log "firing with timeout! timeout: #{@timeout}"
            if @waiting
                @fire {reason: \timeout}
