#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "math.h"
void print_game_board(int board[][3]){
    for(int i = 0; i < 3; i++){
        printf("+---+---+---+\n");
        for(int j = 0; j < 3; j++){
            if(board[i][j] == 0){
                printf("|   ");
            }
            else{
                printf("| %d ", board[i][j]);
            }
        }
        printf("|\n");
    }
    printf("+---+---+---+\n");
}

void add_random_two_to_board(int board[][3]){
    int r = rand() % 9;
    int i = r / 3;
    int j = r % 3;
    while(board[i][j] != 0){
        r = rand() % 9;
        i = r / 3;
        j = r % 3;
    }
    board[i][j] = 2;
}

int main(){
    int game_board[3][3] = {{0,0,0}, {0,0,0}, {0,0,0}};
    printf("Choose [1] or [2]: \n[1] New Game\n[2] Start from a State\n");
    int new_game_input;
    scanf("%d", &new_game_input);
    add_random_two_to_board(game_board);
    print_game_board(game_board);
}