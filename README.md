# qbx_vehiclekeys
Vehicle Keys System For QBOX

## Features
- Security oriented architecture. Client input is not trusted except when absolutely needed
- Touchless entry for key holders of vehicles
- Vehicles can only be hotwired once (statebag)
- Lockpicked vehicles are unlocked for all until ignition is picked.
- Keys can be added and removed by admins (enforced by serverside)
- Shared job vehicles automatically grant keys upon any interaction
- Giving keys supports by id, for all passengers, and nearest player
- Exports provided to remove keys upon being garaged (garage script specific integration required)
- Multiple players entering the same car at once doesn't cause a jam and lock players out
- Flexible configuration options for hotwire chance, carjack chance, etc.
- Backwards compatability is provided for resources that use old netevents.
- Comments to mark where to integrate evidence and boosting resource code


## Dependencies
- [qbx_core](https://github.com/Qbox-project/qbx_core)
- [ox_lib](https://github.com/overextended/ox_lib)

## Installation
### Manual
- Download the script and put it in the `[qbx]` directory.
- Restart Script / Server