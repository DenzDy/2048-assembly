#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "math.h"
void print_game_board(int board[][6])
{
    for (int i = 0; i < 6; i++)
    {
        printf("+----+----+----+----+----+----+\n");
        for (int j = 0; j < 6; j++)
        {
            if (board[i][j] == 0)
            {
                printf("|   ");
            }
            else
            {
                if (board[i][j] <= 10)
                {
                    printf("|  %d ", board[i][j]);
                }
                else if (board[i][j] >= 100)
                {
                    printf("| %d ", board[i][j]);
                }
                else
                {
                    printf("|%d", board[i][j]);
                }
            }
        }
        printf("|\n");
    }
    printf("+----+----+----+----+----+----+\n");
    return;
}

void add_random_two_to_board(int board[][6])
{
    int r = rand() % 36;
    int i = r / 6;
    int j = r % 6;
    while (board[i][j] != 0)
    {
        r = rand() % 36;
        i = r / 6;
        j = r % 6;
    }
    printf("2 placed at (%d, %d)\n", i + 1, j + 1);
    board[i][j] = 2;
}

int check_if_board_is_full(int board[][3])
{
    for (int i = 0; i < 6; i++)
    {
        for (int j = 0; j < 6; j++)
        {
            if (board[i][j] == 0)
            {
                return 0;
            }
        }
    }
    return 1;
}

int check_win_state(int board[][6])
{
    int return_value = 0;
    for (int i = 0; i < 6; i++)
    {
        for (int j = 0; j < 6; j++)
        {
            if (j + 1 < 6 && board[i][j] == board[i][j + 1] && board[i][j] != 0)
            {
                return_value = 2;
            }
            else if (i + 1 < 6 && board[i][j] == board[i + 1][j] && board[i][j] != 0)
            {
                return_value = 2;
            }
            else if (board[i][j] == 0)
            {
                return_value = 2;
            }
            if (board[i][j] == 512)
            {
                return 1;
            }
        }
    }
    return return_value;
}

int swipe_board(char input, int board[][6], int prev_swipe)
{
    if (input == 'W')
    {
        int z = 36;
        while (z != 0)
        {
            z = 0;
            for (int i = 0; i < 6; i++)
            {
                int l = 0;
                for (int j = 1; j <= 6; j++)
                {
                    int k = j;
                    while (k > 0)
                    {
                        if (board[k - 1][i] == 0 && board[k][i] != 0)
                        {
                            z++;
                            board[k - 1][i] += board[k][i];
                            board[k][i] = 0;
                        }
                        k--;
                    }
                }
                for (int j = 1; j < 6; j++)
                {
                    if (board[j - 1][i] == board[j][i] && board[j][i] != 0)
                    {
                        z++;
                        board[j - 1][i] += board[j][i];
                        board[j][i] = 0;
                    }
                }
                for (int j = 1; j < 6; j++)
                {
                    int k = j;
                    while (k > 0)
                    {
                        if (board[k - 1][i] == 0 && board[k][i] != 0)
                        {
                            z++;
                            board[k - 1][i] += board[k][i];
                            board[k][i] = 0;
                        }
                        k--;
                    }
                }
            }
        }
    }

    else if (input == 'X')
    {
        return -1;
    }
    else if (input == '3')
    {
        return 1;
    }
    else if (input == '4')
    {
        return 2;
    }
    return prev_swipe;
}

void board_config(int game_board[][3])
{
    printf("Enter a board configuration: \n");
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            int input;
            scanf("%d", &input);
            game_board[i][j] = input;
        }
    }
}

int main()
{
    int game_board[6][6] = {{4, 0, 0, 0, 0, 0}, {2, 0, 0, 0, 0, 0}, {2, 0, 0, 0, 0, 0}, {2, 0, 0, 0, 0, 0}, {2, 0, 0, 0, 0, 0}, {2, 0, 0, 0, 0, 0}};
    printf("Choose [1] or [2]: \n[1] New Game\n[2] Start from a State\n");
    int new_game_input;
    int swipe_return = 0;
    while (1 == 1)
    {
        char swipe_input;
        print_game_board(game_board);
        printf("Enter a swipe:");
        scanf("\n%c", &swipe_input);
        swipe_return = swipe_board(swipe_input, game_board, swipe_return);
    }
}