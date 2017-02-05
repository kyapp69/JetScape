/***************************************** 
*                                        *
*  Author: Gabriel Grimberg.             *
*  Module: Object Oriented Programming.  *
*  Type: Assignment 2.                   *
*  Language: Java (Processing).          *
*  Start Date: 9th of December 2016.     *
*  Due Date: 7th of February 2017.       *
*                                        *
******************************************/

/* 
  - #DEFINE -
*/
//Amount of coins to spawn.
int COINSPAWN = 100;
int DANGERSPWAN = 100;
/*
  - Imports -
*/
import de.ilu.movingletters.*; //Lib for the text format.
import processing.sound.*; //Lib for the sound format.
import ddf.minim.*;

/* Sound Files */
Minim minim;
AudioPlayer bClick;    // Button Click.
AudioPlayer cCollect;  // Coin Collecting.
AudioPlayer introM;    // INtroduction Music.
AudioPlayer gameMusic; // In game Music.

/* 
  - Array Lists -
*/
ArrayList<MainObjects> mainObjects = new ArrayList<MainObjects>();
/* 
  - Classes -
*/
/*Creating Objects for the Menu. */
MenuButtons StartGame; //Button to start game.
MenuButtons EndGame; //Button to end game.

/*
  - New Objects -
*/
/* Player Object */
Player player = new Player(250,250,4,70,90,' ');

/* Jetflame Object */
Jetflame jetflame = new Jetflame();

/* Coin Objects */
Coin[] coins = new Coin[COINSPAWN];

Danger[] danger = new Danger[COINSPAWN];

/* Speed Control Object */
SpeedControl sControl = new SpeedControl();

/* Text Objects. */
MovingLetters[] Word = new MovingLetters[3]; //<- How many enums.

/* Keys Pressed. */
boolean[] keys = new boolean[COINSPAWN];

/*
  - Images -
*/
//Player sprite.
PImage playerChar;

//Jetpack sprite.
PImage jetpackImg;

//Repeating background.
PImage []background = new PImage[2];
float []repeatBg = new float[2];

/* 
  - Global Variables -
*/
//Boolean Variables for MenuButtons Class.
boolean msbtnStr = false; //Variable to check if the mouse is on the box.
boolean mscbtnStr = false; //Variable to highlight if box is pressed.

boolean msbtnEnd = false; //Variable to check if the mouse is on the box.
boolean mscbtnEnd = false; //Variable to highlight if box is pressed.

//Variables for out of bounds (for player).
float blockWidth, blockHeight, blockXPos, blockYPos, blockSpeed;

//Variable for the speed of the player going down.
float gravity = 5;

//Gamestate Variable.
int gameState = 0;

//Speed variables.
int speed = 3;
int speedBg = 5; //Background speed.
int speedc = 5; //Coin Speed.
int speedDanger = 5;

float coinXPos, coinYPos; //Coin location.
float dangerXPos, dangerYPos; //Coin location.

float theta = 0.0f;
float thetaDanger = 0.0f;
float radius;
float radiusDanger;

//Score counter
int score;

/* Background Speed Change */
float timeDelta = 0;
float timeAccumulator = 0;
int last = 0;

public void setup()
{
  //Size of screen.
  size(1200,600);
  
  frameRate(60);
  
  speedSet();
  
  /* Creating new Objects for MenuButtons */
  StartGame = new MenuButtons(width / 2, 250, 50, 5);
  EndGame = new MenuButtons(width / 2, 450, 50, 5);
  
  mainObjects.add(player);
  
  //Setting up the text.
  for(TextForm Amount : TextForm.values())
  {
    Word[Amount.Pos] = new MovingLetters(this, Amount.Size, 0, 0);
  }
  
  minim = new Minim(this);
  
  bClick = minim.loadFile("Click.mp3");
  gameMusic = minim.loadFile("gameMusic.wav");
  cCollect = minim.loadFile("coin.wav");
  
  loadImages();
  
  movingObjects();
}

public void mousePressed()
{
  quitClicked();
  startClicked();
}

public void mouseReleased() 
{
  //If mouse released set it back to false.
  mscbtnStr = false;
  mscbtnEnd = false; 
}

public void keyPressed()
{
  keys[keyCode] = true;
}

public void keyReleased()
{
  keys[keyCode] = false;
}

public boolean keyCheck(int x)
{
  if (keys.length >= x) 
  {
    return keys[x] || keys[Character.toUpperCase(x)];  
  }
  return false;
}

public void textDisplay(String text, TextForm size, int x, int y)
{
  Word[size.Pos].text(text, x, y);  
}

void playSound(AudioPlayer sound)
{
  if(sound == null)
  {
    return;
  }
  
  sound.rewind();
  sound.play(); 
}

public void MainMenu()
{
  background(0);
  
  if(frameCount / 30 % 2 == 0)
  {
    stroke(255);
    textDisplay("JetScape", TextForm.Biggest, 450, 75);
  }
  
  //Start button with the start text.
  StartGame.StartButton();
  stroke(0);
  textDisplay("Start", TextForm.Big, 540, 230);
  
  //End button with the end text.
  EndGame.EndButton();
  stroke(0);
  textDisplay("Quit", TextForm.Big, 560, 430);
  
}

public void quitClicked()
{
  if(msbtnEnd == true) //If true
  {     
    mscbtnEnd = true; //Set variable to true
    fill(255, 255, 255); //To highlight the box.
    exit(); //Terminating the program
  } 
  else 
  {
    mscbtnEnd = false; //If not, set to false.
  }
}

public void startClicked()
{
  if(msbtnStr == true) //If true
  {
    mscbtnStr = true; //Set variable to true
    fill(255, 255, 255); //To highlight the box.
    playSound(bClick);
    playSound(gameMusic);
    gameState = 1;
  } 
  else 
  {
    msbtnStr = false; //If not, set to false.
  }
}

public void movingBackground()
{
  //Outter Background scrolling.
  for(int i = 0; i < repeatBg.length; i++)
  {
    image(background[i],repeatBg[i],0);
    repeatBg[i] = repeatBg[i] - speedBg;
    
    if(repeatBg[i] + width <= 0)
    {
      repeatBg[i] = width;
    }  
  }
  
}

/* Method to plot the coins */
public void movingObjects()
{  
  for(int i = 0; i < COINSPAWN; i++)
  {
    float loc = coinYPos + sin(theta) * radius;
    
    coins[i] = new Coin(width + 400 * i, loc, 20, 20); //Coins instances.
    theta = theta + random(0f,500f); //Choosing a random location.
    radius = 150; //Spreading out the coins.
  }
  
  for(int i = 0; i < DANGERSPWAN; i++)
  {
    float location = dangerYPos + sin(thetaDanger) * radiusDanger;
    
    danger[i] = new Danger(width + 500 * i, location, 60, 60); //Coins instances.
    thetaDanger = thetaDanger + random(0f,500f); //Choosing a random location.
    radiusDanger = 150; //Spreading out the dangers
  }
}

/* Method to display the coins */
public void displayObjects()
{
  for(int i = 0; i < COINSPAWN; i++)
  {
    fill(255,255,0);
    coins[i].update();
  }
  
  for(int i = 0; i < DANGERSPWAN; i++)
  {
    fill(255,0,0);
    danger[i].update();
  }
}

/* Method to display score */
public void scoreDisplay()
{
  stroke(255);
  textDisplay("Score: " + score, TextForm.Normal, 10, 10);
}

/* Method to load up images */
public void loadImages()
{
  //Player Character
  playerChar = loadImage("Player.png");
  
  jetpackImg = loadImage("Jetflame.png");
  
  //Loading the background image.
  for(int i = 0; i < 2; i ++)
  {
    background[i] = loadImage("Background.png");
    repeatBg[i] = width * i;
  }  
}

/* Method to set the speed. */
public void speedSet()
{
  blockWidth = 50; //Limit to where player walks.
  blockHeight = blockWidth;
  blockYPos = height - blockWidth;
  blockSpeed = 5;
  
  coinXPos = width * 0.5f;
  coinYPos = height * 0.5f;
  
  dangerXPos = width * 0.5f;
  dangerYPos = height * 0.5f;
}
  
public void draw()
{
  switch(gameState)
  {
    case 0:
      MainMenu();
      break;
    case 1:
      clear();
      noCursor();
      movingBackground();
      player.update();
      jetflame.update();
      displayObjects();
      scoreDisplay();
      //sControl.cSpeedChange();
      break;     
  }
  
}