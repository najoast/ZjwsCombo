local tinsert = table.insert

local Combinations = {}

local function Backtrack(N, currentCombination, remainingNumbers, combinations)
    if #currentCombination == N then
        tinsert(combinations, currentCombination)
        return
    end

    for i, num in ipairs(remainingNumbers) do
        local newCombination = {}
        for j, n in ipairs(currentCombination) do
            tinsert(newCombination, n)
        end
        tinsert(newCombination, num)

        local newRemainingNumbers = {}
        for j = 1, #remainingNumbers do
            if j ~= i then
                tinsert(newRemainingNumbers, remainingNumbers[j])
            end
        end

        Backtrack(N, newCombination, newRemainingNumbers, combinations)
    end
end

function Combinations.GenerateAllCombinations(N)
    local combinations = {}
    local initialCombination = {}
    local remainingNumbers = {}

    for i = 1, N do
        tinsert(remainingNumbers, i)
    end

    Backtrack(N, initialCombination, remainingNumbers, combinations)

    return combinations
end

return Combinations
