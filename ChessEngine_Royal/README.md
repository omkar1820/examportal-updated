# ♟️ Java Chess Engine

A complete, production-grade chess engine built in **pure Java 17+** — no frameworks, no external libraries.

Supports **Human vs Human**, **Human vs AI**, and **2-Player Network** modes.

---

## 📦 Project Structure

```
ChessEngine/
├── src/chess/
│   ├── model/           ← Game state (Board, Piece, Move, Position, enums)
│   ├── engine/          ← Move logic, AI, evaluation
│   ├── network/         ← TCP server/client for online play
│   ├── ui/              ← Console interface and entry point
│   └── util/            ← FEN, PGN, Perft, Opening Book
├── out/                 ← Compiled .class files (after build)
├── compile.sh           ← One-command build script
├── run.sh               ← One-command run script
└── README.md
```

---

## ⚙️ Requirements

| Requirement | Version |
|---|---|
| Java JDK | 17 or higher |
| Operating System | macOS, Linux, Windows |
| External Libraries | **None** |

### Install Java on macOS

```bash
# Using Homebrew
brew install openjdk@17

# Or download from:
# https://adoptium.net/
```

Verify your install:
```bash
java -version   # should show 17+
javac -version  # should show 17+
```

---

## 🚀 Quick Start

### Step 1 — Clone / Extract

```bash
unzip ChessEngine.zip
cd ChessEngine
```

### Step 2 — Compile

```bash
chmod +x compile.sh
./compile.sh
```

You should see:
```
Compiling Chess Engine...
Build successful!
```

### Step 3 — Run

```bash
./run.sh
# OR
java -cp out chess.ui.Main
```

---

## 🎮 Game Modes

### Mode 1: Local Game (Human vs Human or vs AI)

```bash
java -cp out chess.ui.Main
```

```
┌─────────────────────────────────┐
│   Chess Engine v1.0 - Startup   │
├─────────────────────────────────┤
│  1) Local game                  │
│  2) Start network server        │
│  3) Connect as network client   │
└─────────────────────────────────┘
Choose: 1
```

Then select sub-mode:
```
╔════════════════════════════════╗
║    Java Chess Engine v1.0      ║
╠════════════════════════════════╣
║  1) Human vs Human             ║
║  2) Human vs AI                ║
╚════════════════════════════════╝
Mode: 2

Play as (W/B): W
AI depth (1-5, default 3): 3
```

### Mode 2: Network Game (2 Machines or 2 Terminal tabs)

**Terminal 1 — Start Server:**
```bash
java -cp out chess.ui.Main
# Choose: 2
```

**Terminal 2 — Player 1 connects:**
```bash
java -cp out chess.ui.Main
# Choose: 3
```

**Terminal 3 — Player 2 connects:**
```bash
java -cp out chess.ui.Main
# Choose: 3
```

> To play over LAN: edit `HOST` in `ChessClient.java` from `"localhost"` to the server's IP address, then recompile.

---

## ♟️ How to Play

### Move Format

Moves use **UCI notation**: `fromSquare + toSquare`

```
e2e4     ← pawn from e2 to e4
g1f3     ← knight from g1 to f3
e1g1     ← kingside castling (king moves 2 squares)
e1c1     ← queenside castling
e7e8q    ← pawn promotion to queen (q/r/b/n)
```

### In-Game Commands

| Command | Description |
|---|---|
| `e2e4` | Make a move |
| `moves` | Show all legal moves |
| `fen` | Print current board as FEN string |
| `save` | Save game as `.pgn` file |
| `resign` | Resign the game |
| `help` | Show command reference |

### Network-Only Commands

| Command | Description |
|---|---|
| `chat hello` | Send a chat message to opponent |
| `draw` | Offer or accept a draw |
| `resign` | Resign the game |

---

## 🤖 AI System

### Algorithm
The AI uses **Minimax with Alpha-Beta Pruning**, extended with:

| Feature | Description |
|---|---|
| **Iterative Deepening** | Searches depth 1 → N, returns best at max depth |
| **Alpha-Beta Pruning** | Cuts off branches that can't affect outcome |
| **Transposition Table** | Zobrist-hashed cache — avoids re-searching seen positions |
| **Quiescence Search** | Extends search on captures to avoid horizon effect |
| **Opening Book** | Pre-stored responses for common openings (first 4 moves) |
| **Move Ordering** | Captures searched first → better pruning efficiency |

### Depth Guide

| Depth | Moves/sec (approx.) | Skill Level |
|---|---|---|
| 1 | Instant | Random-ish |
| 2 | Instant | Beginner |
| 3 | < 1 sec | Intermediate |
| 4 | 1–5 sec | Advanced |
| 5 | 5–30 sec | Strong amateur |

### Evaluation Function

The AI evaluates positions using **material + piece-square tables**:

```
Score = Σ(piece_value + position_bonus) for WHITE
      - Σ(piece_value + position_bonus) for BLACK
```

| Piece | Value |
|---|---|
| Pawn | 100 |
| Knight | 320 |
| Bishop | 330 |
| Rook | 500 |
| Queen | 900 |
| King | 20,000 |

Each piece also has an 8×8 position bonus table that rewards good squares (e.g. knights near the center, pawns advanced, rooks on open files).

---

## ✅ Chess Rules Implemented

| Rule | Status |
|---|---|
| All piece movements | ✅ |
| Castling (kingside + queenside) | ✅ |
| En passant capture | ✅ |
| Pawn promotion (Q, R, B, N) | ✅ |
| Check detection | ✅ |
| Checkmate detection | ✅ |
| Stalemate detection | ✅ |
| 50-move draw rule | ✅ |
| Illegal move rejection | ✅ |
| Pins (moving into check blocked) | ✅ |

---

## 🔧 Utilities

### Perft Test (Verify Move Generator)

Run this to confirm the move generator produces correct results:

```bash
java -cp out chess.util.PerftTest
```

Expected output:
```
=== Perft Test - Starting Position ===
Expected: depth1=20  depth2=400  depth3=8902  depth4=197281

  depth 1 ->      20  (  0 ms)  PASS
  depth 2 ->     400  (  1 ms)  PASS
  depth 3 ->   8,902  (  8 ms)  PASS
  depth 4 -> 197,281  ( 45 ms)  PASS
```

All 4 must show **PASS**. If any fails, there is a move generation bug.

### FEN Import / Export

In-game, type `fen` to see the current position as a FEN string.

In code:
```java
// Export
String fen = new FENParser().toFEN(board);

// Import
Board board = FENParser.fromFEN("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1");
```

### PGN Save

In-game, type `save` to write the current game to a `.pgn` file.

The file is saved in the current directory as `game_<timestamp>.pgn` and can be opened in any chess GUI (Lichess, Chess.com, ChessBase, etc.).

---

## 📁 File Reference

### `src/chess/model/`

| File | Purpose |
|---|---|
| `Color.java` | `WHITE` / `BLACK` enum with `opposite()` |
| `PieceType.java` | `KING QUEEN ROOK BISHOP KNIGHT PAWN` with values |
| `Piece.java` | Piece with type, color, hasMoved flag |
| `Position.java` | Row/col coordinates, algebraic notation conversion |
| `Move.java` | Move with from/to/type/promotionPiece, parser |
| `Board.java` | 8×8 grid, full game state, move application |

### `src/chess/engine/`

| File | Purpose |
|---|---|
| `MoveGenerator.java` | Full legal move generation for all pieces |
| `Evaluator.java` | Material + piece-square table scoring |
| `TranspositionTable.java` | Zobrist hash cache for AI positions |
| `ChessAI.java` | Minimax + Alpha-Beta + TT + Quiescence + Iterative Deepening |
| `GameEngine.java` | High-level game controller, legal move validation |

### `src/chess/network/`

| File | Purpose |
|---|---|
| `ChessMessage.java` | Serializable message passed over TCP |
| `ChessServer.java` | TCP server, connects 2 players, relays moves |
| `ChessClient.java` | TCP client, handles I/O and opponent messages |

### `src/chess/ui/`

| File | Purpose |
|---|---|
| `ConsoleUI.java` | Console game loop, Human vs Human / vs AI |
| `Main.java` | Entry point, mode selection |

### `src/chess/util/`

| File | Purpose |
|---|---|
| `FENParser.java` | FEN string import and export |
| `PGNWriter.java` | Save game to `.pgn` with SAN notation |
| `PGNReader.java` | Load and parse `.pgn` files |
| `OpeningBook.java` | Built-in opening responses for first 4 moves |
| `PerftTest.java` | Move generator correctness verification |

---

## 🛠️ Extending the Project

### Add Longer Opening Book
Edit `OpeningBook.java` — add more entries to the `BOOK` map using the same key format (`"e2e4,e7e5,g1f3,..."` → list of responses).

### Stronger AI
- Increase depth to 5+ (slower but stronger)
- Add **null move pruning** in `ChessAI.alphaBeta()`
- Add **killer move heuristic** to move ordering
- Add **late move reductions (LMR)**
- Add **endgame piece-square tables** in `Evaluator.java`

### GUI
Replace `ConsoleUI.java` with a `javax.swing` GUI:
- `JFrame` with `JPanel` for the board
- `paintComponent()` to draw pieces
- `MouseListener` for click-to-move
- All game logic stays the same — only the UI changes

### UCI Protocol
Implement the **Universal Chess Interface (UCI)** to plug this engine into any chess GUI (Arena, Cute Chess, etc.):
- Read commands from `stdin`: `uci`, `isready`, `position`, `go`
- Write responses to `stdout`: `id name`, `bestmove`
- Engine logic in `ChessAI.java` stays unchanged

---

## 🐛 Troubleshooting

| Problem | Fix |
|---|---|
| `javac: command not found` | Install JDK 17+, not just JRE |
| `java.lang.UnsupportedClassVersionError` | Recompile with your installed JDK version |
| Network client can't connect | Make sure server is running first, check firewall on port 5555 |
| AI takes too long | Reduce depth to 3 |
| Perft test shows FAIL | Check `MoveGenerator.java` for bugs using `divide()` method |

---

## 📜 License

Free to use, modify, and distribute for educational purposes.

---

*Built with pure Java 17 — no frameworks, no dependencies.*
