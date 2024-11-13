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
    return;
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

int check_win_state(int board[][3]){
    int return_value = 0;
    for(int i = 0; i < 3; i++){
        for(int j = 0; j < 3; j++){
            if(j + 1 < 3 && board[i][j] == board[i][j+1] && board[i][j] != 0){
                return_value = 2;
            }
            else if(i + 1 < 3 && board[i][j] == board[i+1][j] && board[i][j] != 0){
                return_value = 2;
            } 
            if(board[i][j] == 512){
                return 1;
            }
        }
    }
    return return_value;
}

void swipe_board(char input, int board[][3]){
    if(input == 'W'){
        for(int i = 0; i < 3; i++){
            for(int j = 1; j <= 2; j++){
                int k = j;
                while(k >= 0){
                    if(board[k-1][i] == 0 || board[k-1][i] == board[k][i]){
                        board[k-1][i] += board[k][i];
                        board[k][i] = 0;
                    }
                    k--;
                }
            }
        }
    }
    else if(input == 'A'){
        for(int i = 0; i < 3; i++){
            
        }
    }
    else if(input == 'S'){
        for(int i = 0; i < 3; i++){
            
        }
    }
    else{
        for(int i = 0; i < 3; i++){
            
        }
    }
}

int main(){
    int game_board[3][3] = {{0,0,0}, {0,0,0}, {0,0,0}};
    printf("Choose [1] or [2]: \n[1] New Game\n[2] Start from a State\n");
    int new_game_input;
    scanf("%d", &new_game_input);
    while(1==1){
        char swipe_input;
        add_random_two_to_board(game_board);
        print_game_board(game_board);
        printf("Enter a swipe:");
        scanf("\n%c", &swipe_input);
        swipe_board(swipe_input, game_board);
    }
}