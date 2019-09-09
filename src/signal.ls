require! '../deps': {sleep, Logger}
require! 'prelude-ls': {is-it-NaN}

export class Signal
    (opts={}) ->
        if opts.debug
            @debug = yes
        @name = opts.name or \Signal
        @log = new Logger @name
        @response = []
        @callback = {ctx: null, handler: null}
        if @debug => @log.debug "Initialized new signal."
        @reset!

    cancel: ->
        @reset!

    reset: ->
        # clear everything like the object is
        # initialized for the first time
        #@log.debug "Resetting signal."
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
        params = unless @error then @response else []
        {handler, ctx} = @callback
        t0 = Date.now!
        err = @error
        set-immediate ~>
            @reset!
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
            @log.error "Can not wait over and over, skipping this one."
            return

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

    go: (err, ...args) ->
        if @skip-next
            @skip-next = no
            return
        @should-run = yes
        @response = args
        @error = err
        #@log.log "called 'go!' (was waiting: #{@waiting})" , @response
        if @waiting
            @fire!

    heartbeat: (duration) ->
        #@log.log "Heartbeating..........."
        if duration > 0
            #@log.log "setting new timeout: #{duration}"
            @timeout = duration
        try clear-timeout @timer
        @timer = sleep @timeout, ~>
            if @waiting
                @should-run = yes
                #@log.log "firing with timeout! timeout: #{@timeout}"
                if typeof! @timeout-handler is \Function 
                    @timeout-handler!
                else 
                    @error = \TIMEOUT
                    @fire!

    on-timeout: (callback) -> 
        @timeout-handler = callback 