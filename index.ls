require! './src/signal': {Signal}
require! './src/signal-branch': {SignalBranch}

module.exports = {
    Signal, SignalBranch
}

global.Signal = Signal
global.SignalBranch = SignalBranch 
