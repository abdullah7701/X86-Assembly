#include <stdint.h>
#include <stdio.h>

void unionfind(uint64_t setSize, char *instruction_string, char *solution_string);

int main() {
    char instruction_string[] = "U0&1 U1&2 F2 F0";
    char solution_string[256] = {0};
    uint64_t setSize = 3;

    unionfind(setSize, instruction_string, solution_string);

    printf("Output: %s\n", solution_string);
    return 0;
}