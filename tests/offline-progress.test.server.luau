local OfflineProgress = require(script.Parent:WaitForChild("OfflineProgress"))

local options = {
    MaxOfflineSeconds = 3600,
    Efficiency = 0.5,
    MaxReward = 1000,
}

local firstRun = OfflineProgress.Calculate(0, 10000, 2, options)
assert(firstRun ~= nil, "First-run calculation should succeed")
assert(firstRun.Reward == 0, "First run must not grant an unearned interval")
assert(firstRun.NextSimulationAt == 10000, "First run must initialize the timestamp")

local oneHour = OfflineProgress.Calculate(10000, 13600, 2, options)
assert(oneHour ~= nil, "One-hour calculation should succeed")
assert(oneHour.ElapsedSeconds == 3600, "One-hour elapsed time mismatch")
assert(oneHour.Reward == 1000, "Reward cap should be applied")
assert(oneHour.NextSimulationAt == 13600, "Timestamp should advance to server time")

local cappedDuration = OfflineProgress.Calculate(10000, 20000, 1, options)
assert(cappedDuration ~= nil, "Capped-duration calculation should succeed")
assert(cappedDuration.ElapsedSeconds == 3600, "Offline duration cap should apply")
assert(cappedDuration.Reward == 1000, "Reward cap should apply")

local futureTimestamp = OfflineProgress.Calculate(20000, 10000, 5, options)
assert(futureTimestamp ~= nil, "Future timestamp should return a safe result")
assert(futureTimestamp.Reward == 0, "Future timestamp must not grant rewards")
assert(futureTimestamp.NextSimulationAt == 20000, "Future timestamp must not be moved backwards")
assert(futureTimestamp.ClockWasBehind == true, "Clock anomaly should be reported")

local negativeRate, negativeRateError = OfflineProgress.Calculate(10000, 11000, -1, options)
assert(negativeRate == nil, "Negative production rate must be rejected")
assert(negativeRateError == "invalid_configuration", "Negative rate error mismatch")

local overflowOptions = {
    MaxOfflineSeconds = 3600,
    Efficiency = math.huge,
    MaxReward = 1000,
}
local invalidConfig, invalidConfigError = OfflineProgress.Calculate(10000, 11000, 1, overflowOptions)
assert(invalidConfig == nil, "Non-finite efficiency must be rejected")
assert(invalidConfigError == "invalid_input", "Non-finite config error mismatch")

print("OfflineProgress tests passed")
