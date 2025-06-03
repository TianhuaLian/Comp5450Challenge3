enum GameState {
  title,        // Start screen
  aiming,       // Adjusting throw angle and power
  rolling,      // Ball in motion
  checkingPins, // Evaluating pin status
  frameEnd,     // Between frames
  gameOver,     // After 10 frames
  pause,        // Game paused
}