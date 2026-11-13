local OfflineProgress = {}

local function isFiniteNumber(value)
    return typeof(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
end

function OfflineProgress.Calculate(lastSimulationAt, now, ratePerSecond, options)
    if typeof(options) ~= "table" then
        return nil, "invalid_options"
    end

    local maxOfflineSeconds = options.MaxOfflineSeconds
    local efficiency = options.Efficiency
    local maxReward = options.MaxReward

    if not isFiniteNumber(lastSimulationAt)
        or not isFiniteNumber(now)
        or not isFiniteNumber(ratePerSecond)
        or not isFiniteNumber(maxOfflineSeconds)
        or not isFiniteNumber(efficiency)
        or not isFiniteNumber(maxReward) then
        return nil, "invalid_input"
    end

    if lastSimulationAt < 0
        or now <= 0
        or ratePerSecond < 0
        or maxOfflineSeconds < 0
        or efficiency < 0
        or maxReward < 0 then
        return nil, "invalid_configuration"
    end

    if lastSimulationAt == 0 then
        return {
            ElapsedSeconds = 0,
            Reward = 0,
            NextSimulationAt = now,
            ClockWasBehind = false,
            IsFirstSimulation = true,
        }
    end

    local rawElapsed = now - lastSimulationAt

    if not isFiniteNumber(rawElapsed) then
        return nil, "invalid_elapsed_time"
    end

    if rawElapsed < 0 then
        return {
            ElapsedSeconds = 0,
            Reward = 0,
            NextSimulationAt = lastSimulationAt,
            ClockWasBehind = true,
            IsFirstSimulation = false,
        }
    end

    local elapsed = math.min(rawElapsed, maxOfflineSeconds)
    local rawReward = ratePerSecond * elapsed * efficiency

    if not isFiniteNumber(rawReward) then
        return nil, "reward_overflow"
    end

    local reward = math.min(rawReward, maxReward)

    return {
        ElapsedSeconds = elapsed,
        Reward = reward,
        NextSimulationAt = now,
        ClockWasBehind = false,
        IsFirstSimulation = false,
    }
end

return OfflineProgress
