/***********************************************************************
* File       : <wraparound.c>
*
* Author     : <M.R. Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/19
*
***********************************************************************/
// ==========================================================================
// 2D String Finder
// ==========================================================================
// Finds the matching words from dictionary in the 2D grid, including wrap-around

// Inf2C-CS Coursework 1. Task 6
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2019

#include <stdio.h>

// maximum size of each dimension
#define MAX_DIM_SIZE 32
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 1000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 10

int read_char() { return getchar(); }
int read_int()
{
  int i;
  scanf("%i", &i);
  return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }
void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
const char dictionary_file_name[] = "dictionary.txt";
// grid file name
const char grid_file_name[] = "2dgrid.txt";
// content of grid file
char grid[(MAX_DIM_SIZE + 1 /* for \n */ ) * MAX_DIM_SIZE + 1 /* for \0 */ ];
// content of dictionary file 
char dictionary[MAX_DICTIONARY_WORDS * (MAX_WORD_SIZE + 1 /* for \n */ ) + 1 /* for \0 */ ];
///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////Put your global variables/functions here///////////////////////

// starting index of each word in the dictionary
int dictionary_idx[MAX_DICTIONARY_WORDS];
// number of words in the dictionary
int dict_num_words = 0;
// function to print found word
void print_word(char *word)
{
  while(*word != '\n' && *word != '\0') {
    print_char(*word);
    word++;
  }
}

// Return length of word even with newline character
int length_of_row(){
  int grid_idx = 0;
  while (grid[grid_idx++] != '\n');
  return grid_idx;
}
// Return length of word even with null character
int length_of_grid(){
  int grid_idx = 0;
  while (grid[grid_idx++] != '\0');
  return grid_idx;
}
// Return number of words the grid had
int number_of_rows(){
  int grid_idx = 0;
  int counter = 0;
  while (grid[grid_idx++] != '\0') {
    if (grid[grid_idx] == '\n') {
      counter++;
    }
  }
  return counter;
}

// function to see if the string contains the (\n terminated) word
int horizontalContain(char *string, char *word){
  int length = length_of_row();
  while (1) {

    if (*string != *word){
      if (*string == '\n') {
        string = string - length + 1;

      } else {
        return (*word == '\n');
      }

    } else {

      if (*word == '\n') { return 1; }
      word++;
      string++;

    }
  }
  return 0;
}

int verticalContain(char *string, char *word, int grid_idx, int number_of_row) {
  int row_length = length_of_row();
  int grid_length = length_of_grid();
  while (1) {
    if (*string != *word) {
      return (*word == '\n');
    }
    if (grid_idx + row_length < grid_length) {
      string = string + row_length;
      word++;
      grid_idx = grid_idx + row_length;
      number_of_row++;
    } else {
      string = string - number_of_row * row_length;
      word++;
      grid_idx = grid_idx - number_of_row * row_length;
      number_of_row = 0;   
    }

  }
}

/*  I implemented it better by checking if the char was in the last row or column
int diagonalContain(char *string, char *word, int grid_idx, int number_of_row, int index_to_print){
  int grid_length = length_of_grid();
  int row_length = length_of_row();
  while (1) {
    if (*string != *word) {
      return (*word == '\n');
    } 
    if (grid_idx + row_length + 1 < grid_length) {
      string = string + row_length + 1;
      word++;
      grid_idx = grid_idx + row_length + 1;
      number_of_row++;
    } else {
      string = string - number_of_row * (row_length + 1);
      word++;
      grid_idx = grid_idx - number_of_row * (row_length + 1);
      number_of_row = 0;
    }
  }
}
*/

int diagonalContain(char *string, char *word, int grid_idx, int row, int column){
  int row_length = length_of_row();
  int rows = number_of_rows();

  while (1) {
    if (*string != *word) {
      return (*word == '\n');
    } 
    // rows - 1 is our last row since we start with row 0
    // row_length - 2 is the second_to_last_index since we start with column 0 not 1
    if (row < rows - 1 && column < row_length - 2) {
      string = string + row_length + 1;
      word++;
      row++;
      column++;
    } else {
      while (column != 0 && row != 0) {
        string = string - (row_length + 1);
        column--;
        row--;
      }
      word++;
      
    }
  }
}


void print_(int number_of_row, int index_to_print, char *word, int v_or_h ){
  char letter;
  switch (v_or_h) {
    case 0:
      letter = 'V';
      break;
    case 1:
      letter = 'H';
      break;
    case 2:
      letter = 'D';
      break;
  }

  print_int(number_of_row);
  print_char(',');
  print_int(index_to_print);
  print_char(' ');
  print_char(letter);
  print_char(' ');
  print_word(word);
  print_char('\n');
}


void strfind()
{
  int length = length_of_row();
  int number_of_row = 0;
  int print_minus_one = 1;
  int j = 0;
  int idx = 0;
  int grid_idx = 0;
  char *word;
  while (grid[grid_idx] != '\0') {

    if (grid[grid_idx] == '\n'){
      grid_idx++;
      idx = 0;
      number_of_row++;
    }

    for(idx = 0; idx < dict_num_words; idx ++) {
      word = dictionary + dictionary_idx[idx]; 
      char *string = grid + grid_idx;

      int index_to_print = grid_idx;                // We subtract the length of  
      for(j = 0; j < number_of_row; j++) {          // the row times the number of rows
        index_to_print -= length;                   // to get the index from 0 to length
      }
      if (horizontalContain(string, word)) {
        print_(number_of_row, index_to_print, word, 1);
        print_minus_one = 0;
      }
      if (verticalContain(string, word, grid_idx, number_of_row)) {
        print_(number_of_row, index_to_print, word, 0);
        print_minus_one = 0;
      } 
 
      if (diagonalContain(string, word, grid_idx, number_of_row, index_to_print)) {
        print_(number_of_row, index_to_print, word, 2);
        print_minus_one = 0;
      }

    }

    grid_idx++;
  }
  if (print_minus_one) { print_string("-1\n"); }
}



//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{

  /////////////Reading dictionary and grid files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;


  // open grid file
  FILE *grid_file = fopen(grid_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the grid file failed
  if(grid_file == NULL){
    print_string("Error in opening grid file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }
  // reading the grid file
  do {
    c_input = fgetc(grid_file);
    // indicates the the of file
    if(feof(grid_file)) {
      grid[idx] = '\0';
      break;
    }
    grid[idx] = c_input;
    idx += 1;

  } while (1);

  // closing the grid file
  fclose(grid_file);
  idx = 0;
   
  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }
    dictionary[idx] = c_input;
    idx += 1;
  } while (1);


  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ///////////////You can add your code here!//////////////////////
  // The code to copy the dictionary is the same as the one given
  // for 1dstrfind.c
  int dict_idx = 0;
  int start_idx = 0;
  idx = 0;
    do {
      c_input = dictionary[idx];
      if(c_input == '\0') {
        break;
      }
      if(c_input == '\n') {
        dictionary_idx[dict_idx ++] = start_idx;
        start_idx = idx + 1;
      }
      idx += 1;
    } while (1);

    dict_num_words = dict_idx;
    strfind();

  return 0;
}
