🛠️ Union-Find Implementation in x86-64 Assembly
Welcome to the Union-Find implementation repository! This project provides an x86-64 assembly solution for handling Union and Find operations with dynamic memory management.

📋 Table of Contents
Overview
Features
Installation
Usage
Contributing
License
Contact
📖 Overview
The Union-Find (Disjoint Set Union) algorithm is a fundamental data structure used to keep track of a partition of a set into disjoint subsets. This project implements Union-Find in x86-64 assembly, featuring path compression and union by rank.

✨ Features
Path Compression: Flattens the structure of the tree whenever Find is called, improving efficiency.
Union by Rank: Attaches the smaller tree under the root of the larger tree, minimizing the height.
Dynamic Memory Allocation: Uses malloc for allocating memory and free for deallocating.
🛠️ Installation
To use this Union-Find implementation, follow these steps:

**Clone the Repository:**

git clone https://github.com/your-username/union-find-asm.git
cd union-find-asm

**Assemble the Code:
Use an assembler like nasm to compile the assembly code:**

nasm -f elf64 -o unionfind.o unionfind.asm


**🚀 Usage
📜 Function Prototype**
global unionfind
extern printf, malloc, free

section .data
FORMAT_FIND db "F%uL%u%c ", 0
FORMAT_UNION db "U%uL%u%c ", 0


💻 Running the Code
Prepare Input: Define your instruction_string and buffer for solution_string.
Call unionfind:
Input: rdi = set size, rsi = instruction string, rdx = buffer for solution string.
Output: Results are stored in solution_string.

📜 License
This project is licensed under the MIT License. See the LICENSE file for details.

📧 Contact
For any questions or suggestions, please contact Abdullah Google my name "abdullah7701".
