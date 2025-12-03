/* 
  a map store play mode rules

  mode: Mode.marathon,
  rule: .....
 */

enum Mode { marathon, sprint, ultra, zen }

class GameRule {
  final int? timeLimit; // seconds, null if unlimited
  final int? lineGoal; // for sprint
  final bool endless; // true for zen
  final bool hasGameOver; // false for zen

  const GameRule({
    this.timeLimit,
    this.lineGoal,
    this.endless = false,
    this.hasGameOver = true,
  });
}

final Map<Mode, GameRule> gameModeRules = {
  Mode.marathon: GameRule(
    timeLimit: null,
    lineGoal: null,
    endless: false,
    hasGameOver: true,
  ),
  Mode.sprint: GameRule(
    timeLimit: null,
    lineGoal: 40,
    endless: false,
    hasGameOver: true,
  ),
  Mode.ultra: GameRule(
    timeLimit: 120, // 2 minutes
    lineGoal: null,
    endless: false,
    hasGameOver: true,
  ),
  Mode.zen: GameRule(
    timeLimit: null,
    lineGoal: null,
    endless: true,
    hasGameOver: false,
  ),
};
