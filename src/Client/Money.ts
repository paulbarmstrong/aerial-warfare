import { getVariable, group, player } from "@paulbarmstrong/js-to-sqf";

export function getPlayerMoney(): number {
    return getVariable(group(player()), "Money") ?? 0
}