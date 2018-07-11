require! './src/signal': {Signal}
require! './src/signal-branch': {SignalBranch}

module.exports = {
    Signal, SignalBranch
}

# For exposing by browserify 
global.Signal = Signal
global.SignalBranch = SignalBranch
